#!/usr/bin/env python3
"""Render the "traffic" block wallpaper from a base16 palette.

A rectangle is cut up by recursive guillotine splits, every cell is
extruded to a random height and drawn in oblique projection with flat
fills and a dark outline. Writes SVG to --out, or stdout.
"""

import argparse
import random
import re
import sys

# Oblique basis, screen px per unit, measured off the reference artwork.
# C drops down *and to the left*, which puts the viewer above, in front and
# to the left of the plane: the top, front and left faces of a box all show,
# so a cell is three quads — A x B for the top, A x C hanging off its front
# edge and B x C off its left edge.
#
# The top faces are what tiles the plane. Raising a box by its height
# instead would slide its top face along C by an amount no neighbour
# shares, so every box would overhang the one to its right and tear a gap
# open on its left.
AX, AY = 1.000, 0.000  # width, left to right
BX, BY = 0.288, 1.000  # depth, back to front
CX, CY = -0.583, 1.000  # down off the front edge, one unit of height

# Everything below is in px on this reference canvas, scaled to fit the
# requested one.
REF_W, REF_H = 2880.0, 1800.0
GROUND_W, GROUND_L = 708.0, 559.0
UNIT_W = 21.0  # the width grid; columns are whole multiples of this
CELL_L = (66.0, 175.0)  # cell extent along B: min, max
STROKE = 3.2

# A cell keeps only part of its slot. The strip left over along the depth
# axis is the gap the block in front needs for this block's front face to
# stay in view; the one along the width axis holds neighbouring columns
# apart and uncovers a sliver of the left face behind it.
# GAP_V has to clear the tallest block, or the one in front rides up over
# the front face and leaves nothing but ground showing. GAP_U comes off
# every cell, so it doubles as how thin a one-unit column ends up.
GAP_U, GAP_V = 7.0, 19.0

# Kept in a narrow band, and under GAP_V: tall next to short is what opens
# grey wedges between neighbours.
HEIGHTS = [14.0, 16.0, 18.0]
HEIGHT_WEIGHTS = [4, 5, 4]

# How far a column's near and far ends wander, so the plane frays at the
# edges instead of every column starting off one straight baseline.
STAGGER = 26.0

# Column widths, as (units, weight). They are whole multiples of CELL_W's
# minimum and nothing else, which is how the original's measure: its pitches
# cluster on ~20, 41, 61 and 88px with no intermediate widths at all. A
# continuous range instead fills that space with almost-matching neighbours,
# and a row of columns that are nearly-but-not-quite equal is what reads as
# repetition.
WIDTH_UNITS = [(1, 64), (2, 20), (3, 4), (4, 12)]

# How often a cell already inside its depth budget is cut across its width
# instead. Nothing else varies a column's width down its own length — a
# column that never does this is one unbroken run of a single width — so it
# has to happen often to show up at all.
SPLIT_U = 0.45

# Relative frequency of each fill, in the order given. From a pixel census
# of the original: one hue carries the picture, one is a rare accent.
WEIGHTS = [1.00, 0.63, 0.61, 0.60, 0.45, 0.38, 0.05]

# base16 accents lined up with WEIGHTS, so yellow dominates and green is
# the once-in-a-while accent.
SCHEME_FILLS = ["base0A", "base09", "base0D", "base0C", "base08", "base0E", "base0B"]

# The original wallpaper's own colours, used when no scheme is given.
FALLBACK_BG = "#414042"
FALLBACK_OUTLINE = "#231f20"
FALLBACK_FILLS = [
    "#fdcf09",
    "#f27255",
    "#217abe",
    "#49b8ba",
    "#83b7e3",
    "#f48b93",
    "#b6aad1",
]


def parse_args(argv):
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--out", default="-")
    p.add_argument("--width", type=int, default=2880)
    p.add_argument("--height", type=int, default=1800)
    p.add_argument("--seed", type=int, default=1)
    p.add_argument("--scheme", help="base16 YAML to take colours from")
    p.add_argument("--background")
    p.add_argument("--outline")
    p.add_argument("--fills", help="comma-separated hex colours")
    p.add_argument("--scale", type=float, default=1.0, help="motif size, 1.0 = as the original")
    return p.parse_args(argv)


def read_scheme(path):
    with open(path) as fh:
        text = fh.read()
    found = {}
    for m in re.finditer(r'^\s*(base0)([0-9A-Fa-f]):\s*"?#?([0-9a-fA-F]{6})"?', text, re.M):
        found[m.group(1) + m.group(2).upper()] = "#" + m.group(3)
    missing = [k for k in ["base00", "base01"] + SCHEME_FILLS if k not in found]
    if missing:
        sys.exit(f"{path}: missing {', '.join(missing)}")
    return found


def darken(color, amount):
    r, g, b = (int(color[i : i + 2], 16) for i in (1, 3, 5))
    return "#%02x%02x%02x" % tuple(round(c * (1.0 - amount)) for c in (r, g, b))


def palette(args):
    bg, outline, fills = FALLBACK_BG, FALLBACK_OUTLINE, FALLBACK_FILLS
    if args.scheme:
        s = read_scheme(args.scheme)
        # base00 and base01 sit too close together in most schemes to read
        # as ground against outline, so the stroke is a darkened base00.
        bg, outline = s["base01"], darken(s["base00"], 0.35)
        fills = [s[k] for k in SCHEME_FILLS]
    return (
        args.background or bg,
        args.outline or outline,
        [c.strip() for c in args.fills.split(",")] if args.fills else fills,
    )


def build_cells(rng, gw, gl, unit_w, min_l, max_l, stagger):
    cells = []

    def column_spans():
        # Take the whole row's worth of widths by target proportion and
        # shuffle, rather than sampling each column independently: only two
        # dozen columns fit, and independent draws come out lumpy enough that
        # a layout can end up all slivers or all slabs.
        total = sum(wt for _, wt in WIDTH_UNITS)
        mean = sum(k * unit_w * wt for k, wt in WIDTH_UNITS) / total
        n = round(gw / mean) + 2
        widths = [
            k * unit_w
            for k, wt in WIDTH_UNITS
            for _ in range(max(1, round(n * wt / total)))
        ]
        rng.shuffle(widths)
        # Deal them out rather than laying the shuffle down as-is, refusing a
        # fourth neighbour of the same width: a plain shuffle clumps five or
        # six slivers in a row, where the original runs at most three.
        spans, u, placed, pool = [], 0.0, [], widths
        while pool:
            fits = [i for i, w in enumerate(pool) if u + w <= gw]
            if not fits:
                break
            spread = [i for i in fits if placed[-3:] != [pool[i]] * 3]
            w = pool.pop((spread or fits)[0])
            spans.append((u, u + w))
            u += w
            placed.append(w)
        return spans

    def carve(u0, u1, v0, v1, depth):
        w, l = u1 - u0, v1 - v0
        # A split is either mandatory, because the cell is over its budget
        # on that axis, or an occasional one for variety. Cutting along the
        # depth axis is the common case; cutting a column's width is rare,
        # which is what lets the wide ones survive as wide ones.
        want_v = l > max_l or rng.random() < 0.55
        units = round(w / unit_w)
        if depth and l >= 2 * min_l and want_v:
            t = min(max(l * rng.uniform(0.2, 0.8), min_l), l - min_l)
            carve(u0, u1, v0, v0 + t, depth - 1)
            carve(u0, u1, v0 + t, v1, depth - 1)
        elif depth and units >= 2 and rng.random() < SPLIT_U:
            # Split on the unit grid too, so the widths a column shows at
            # one depth are the same ones its neighbours show at another.
            t = rng.randint(1, units - 1) * unit_w
            carve(u0, u0 + t, v0, v1, depth - 1)
            carve(u0 + t, u1, v0, v1, depth - 1)
        else:
            cells.append((u0, u1, v0, v1))

    for u0, u1 in column_spans():
        v0 = rng.uniform(0.0, stagger)
        v1 = gl - rng.uniform(0.0, stagger)
        if u1 - u0 <= 2 * unit_w and rng.random() < 0.12:
            cells.append((u0, u1, v0, v1))
        else:
            carve(u0, u1, v0, v1, 7)
    return cells


def project(u, v):
    return (u * AX + v * BX, u * AY + v * BY)


def render(args):
    rng = random.Random(args.seed)
    bg, outline, fills = palette(args)
    weights = (WEIGHTS * (len(fills) // len(WEIGHTS) + 1))[: len(fills)]

    s = min(args.width / REF_W, args.height / REF_H) * args.scale
    cells = build_cells(
        rng,
        GROUND_W * s,
        GROUND_L * s,
        *(x * s for x in (UNIT_W,) + CELL_L + (STAGGER,)),
    )

    # Painter's order: right to left, then back to front. A box's body hangs
    # down and to the left, so the only boxes it can ever reach over are the
    # ones nearer the viewer — further left, or further forward in the same
    # column — and those have to be drawn after it to cover it back up.
    cells.sort(key=lambda c: (-c[0], c[2]))

    quads, xs, ys = [], [], []
    for u0, u1, v0, v1 in cells:
        u1, v1 = u1 - GAP_U * s, v1 - GAP_V * s
        if u1 <= u0 or v1 <= v0:
            continue
        h = rng.choices(HEIGHTS, HEIGHT_WEIGHTS)[0] * s
        top = [project(u0, v0), project(u1, v0), project(u1, v1), project(u0, v1)]

        base = [(x + h * CX, y + h * CY) for x, y in top]
        front = [top[3], top[2], base[2], base[3]]
        left = [top[0], top[3], base[3], base[0]]
        # Left and front only meet along an edge, so between those two the
        # order is free; the top has to come last either way.
        quads.append((rng.choices(fills, weights)[0], left, front, top))
        for x, y in top + base:
            xs.append(x)
            ys.append(y)

    dx = args.width / 2.0 - (min(xs) + max(xs)) / 2.0
    dy = args.height / 2.0 - (min(ys) + max(ys)) / 2.0

    def points(pts):
        return " ".join(f"{x + dx:.2f},{y + dy:.2f}" for x, y in pts)

    out = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{args.width}" '
        f'height="{args.height}" viewBox="0 0 {args.width} {args.height}">',
        f'<rect width="{args.width}" height="{args.height}" fill="{bg}"/>',
        f'<g stroke="{outline}" stroke-width="{STROKE * s:.2f}" stroke-linejoin="round">',
    ]
    for fill, *faces in quads:
        for face in faces:
            out.append(f'<polygon points="{points(face)}" fill="{fill}"/>')
    out += ["</g>", "</svg>", ""]
    return "\n".join(out)


def main():
    args = parse_args(sys.argv[1:])
    svg = render(args)
    if args.out == "-":
        sys.stdout.write(svg)
    else:
        with open(args.out, "w") as fh:
            fh.write(svg)


if __name__ == "__main__":
    main()
