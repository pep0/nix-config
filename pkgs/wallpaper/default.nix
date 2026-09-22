{ lib
, runCommand
, python3
, resvg
, base16Scheme
, width ? 2880
, height ? 1800
, seed ? lib.toInt (lib.fileContents ./seed)
, extraFlags ? [ ]
}:

# Generates the desktop wallpaper from the active base16 scheme, so the
# picture re-themes with the rest of the system instead of being a fixed
# download.
#
# `seed` picks the layout, and being a build input is the only thing that
# makes Nix generate a new one — same seed, same store path, no rebuild.
# `make system` re-rolls ./seed, so each switch gets a fresh picture while
# older generations keep the one they were built with.
runCommand "traffic-wallpaper-${toString width}x${toString height}.png"
{
  nativeBuildInputs = [ python3 resvg ];
} ''
  python3 ${./traffic.py} \
    --scheme ${base16Scheme} \
    --width ${toString width} \
    --height ${toString height} \
    --seed ${toString seed} \
    ${lib.escapeShellArgs extraFlags} \
    --out wallpaper.svg
  resvg wallpaper.svg $out
''
