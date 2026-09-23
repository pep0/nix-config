#!/usr/bin/env python3
"""Render the "traffic" block wallpaper from a base16 palette.

The ground is packed with blocks of random width and depth, every one
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
# The lattice every block edge sits on. Fine enough that it never reads as
# a grid; it only keeps neighbours flush so gaps stay one constant width.
UNIT_W, UNIT_L = 21.0, 11.0
STROKE = 3.2

# A cell keeps only part of its slot. The strip left over along the depth
# axis is the gap the block in front needs for this block's front face to
# stay in view; the one along the width axis holds neighbours apart and
# uncovers a sliver of the left face behind it.
# GAP_V has to clear the tallest block, or the one in front rides up over
# the front face and leaves nothing but ground showing.
GAP_U, GAP_V = 7.0, 19.0

# Drawn continuously from a narrow band, so no two neighbours match
# exactly: tall next to short is what opens grey wedges between them. The
# top must stay under GAP_V, or a body reaches over the block in front.
HEIGHT = (11.0, 18.0)

# Block extents in lattice units, as (units, weight). Width and depth are
# drawn independently, so every aspect shows up — wide flat slabs, long
# thin strips, squares. Both lean small, so the big ones stay rare enough
# to stand out.
WIDTHS = [(1, 30), (2, 26), (3, 16), (4, 9), (5, 5), (6, 3), (8, 1)]
LENGTHS = [(4, 14), (5, 14), (6, 12), (7, 10), (8, 9), (10, 8), (12, 6), (14, 5), (16, 4)]
# Largest block, as width units times depth units. Width and depth are
# otherwise independent; this is what keeps a wide draw shallow while a
# narrow one can still run long.
MAX_AREA = 20
# Shallowest a block may be, in units. Space left in front of a block that
# is shallower than this gets folded into the block instead of left as a
# sliver.
MIN_L = 4

# How many units each lattice column's near and far ends can pull in, so
# the plane frays at the edges instead of ending on a straight line.
FRAY = 3

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


def build_cells(rng, gw, gl, unit_w, unit_l):
    """Skyline packing of the ground on a lattice.

    `sky[u]` is how far column u is filled. Each step fills the lowest flat
    run of the skyline with a block of independently drawn width and depth.
    A plain front-to-back scan instead leaves a jagged frontier whose narrow
    notches clip every block's width but hardly ever its depth, and the
    result is all tall strips.
    """
    nu, nv = int(gw // unit_w), int(gl // unit_l)
    sky = [rng.randint(0, FRAY) for _ in range(nu)]
    end = [nv - rng.randint(0, FRAY) for _ in range(nu)]
    widths, wweights = zip(*WIDTHS)
    lengths, lweights = zip(*LENGTHS)

    def open_(u):
        return end[u] - sky[u] >= MIN_L

    cells = []
    while True:
        todo = [u for u in range(nu) if open_(u)]
        if not todo:
            return cells
        low = min(sky[u] for u in todo)
        a = next(u for u in todo if sky[u] == low)
        b = a
        while b < nu and sky[b] == low and open_(b):
            b += 1

        run = b - a
        w = min(rng.choices(widths, wweights)[0], run)
        u0 = a if rng.random() < 0.5 else b - w
        u1 = u0 + w

        limit = min(end[u0:u1])
        l = rng.choices(lengths, lweights)[0]
        top = low + max(min(l, MAX_AREA // w), MIN_L)
        # Snap level with a neighbour that is nearly level anyway. This is
        # what keeps the skyline flat enough for wide blocks to find room.
        for n in (u0 - 1, u1):
            if (
                0 <= n < nu
                and abs(top - sky[n]) < MIN_L
                and MIN_L <= sky[n] - low <= max(MAX_AREA // w, MIN_L)
            ):
                top = sky[n]
                break
        # Too close to the far edge for another block: pull back to leave
        # room for one, by a random amount so the last row doesn't line up,
        # if that still leaves this one deep enough; else run to the edge.
        if limit - top < MIN_L:
            back = limit - rng.randint(MIN_L, 2 * MIN_L)
            top = back if back - low >= MIN_L else limit
        for u in range(u0, u1):
            sky[u] = top
        cells.append((u0 * unit_w, u1 * unit_w, low * unit_l, top * unit_l))


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
        UNIT_W * s,
        UNIT_L * s,
    )

    # Painter's order: right to left. A box's body hangs down and to the
    # left, over whatever sits beside it on the left, so that has to be
    # drawn after it. Boxes whose depth ranges don't overlap never meet on
    # screen at all — GAP_V clears the tallest body — so right to left is
    # the only order that matters; depth just breaks ties.
    cells.sort(key=lambda c: (-c[0], c[2]))

    quads, xs, ys = [], [], []
    for u0, u1, v0, v1 in cells:
        u1, v1 = u1 - GAP_U * s, v1 - GAP_V * s
        if u1 <= u0 or v1 <= v0:
            continue
        h = rng.uniform(*HEIGHT) * s
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
