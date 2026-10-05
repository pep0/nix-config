# nix-config

Personal [NixOS](https://nixos.org/) flake for two machines. Tracks
`nixos-26.05` stable.

| Host       | Target                                      |
| :--------- | :------------------------------------------ |
| `thinkpad` | ThinkPad P14s Gen 5 (Intel)                 |
| `macbook`  | MacBook Pro Mid 2014, 13" (MacBookPro11,1)  |

Hyprland and niri coexist as login sessions (picked at greetd), themed
Tokyo Night via Stylix. Firefox as the browser, noctalia as the
shell (bar, notifications, launcher, lock, idle, wallpaper). Secrets via sops-nix; Secure Boot via Lanzaboote on
the ThinkPad; TLP with `60/80` charge thresholds on both.

## Layout

- `flake.nix` — outputs and the `mkSystem` helper
- `hosts/<name>/` — per-machine config + hardware
- `modules/system/` — shared system modules
- `modules/desktop/` — generic Wayland infra + Hyprland and niri
- `modules/home/` — home-manager modules (CLI tools, shell, editor,
  compositors, status bar)
- `profile/` — portable user-level package set for **non-NixOS**
  machines (`nix profile install .#profile`). NixOS hosts get the
  same tools via home-manager already; `make profile` is a no-op there.

Keybindings live in `modules/home/hyprland.nix` and
`modules/home/niri.nix`; shared compositor apps + the `screenshot`
wrapper script in `modules/home/wayland-apps.nix`; shell
aliases in `modules/home/shell.nix`; bar layout in
`modules/home/noctalia.nix`. Theme is set by `modules/system/stylix.nix`
(the `base16Scheme` line); explicit color references in code use
`config.lib.stylix.colors.base0X`.

## Daily

```
make system     # rebuild and switch
make home       # rebuild and switch home-manager
make update     # update flake.lock
make diff       # dry-build, show what would change
make rollback   # revert one system generation
make clean      # GC old generations
```

`make` with no args lists targets.

## Setup

- Install or migrate: [INSTALL.md](INSTALL.md)
- Secure Boot bootstrap: [SECUREBOOT.md](SECUREBOOT.md)
- TPM2 auto-unlock for LUKS (after Secure Boot): [TPM-UNLOCK.md](TPM-UNLOCK.md)
- Secrets bootstrap: [SECRETS.md](SECRETS.md)

## Notes

- `modules/system/boot.nix` uses `pkgs.linuxPackages_latest` as a
  `mkDefault`; `macbook` overrides this to `pkgs.linuxPackages`
  because `broadcom-sta` lags behind bleeding-edge kernels. If a
  rebuild on `thinkpad` fails on the NVIDIA kernel module after a
  kernel bump, do the same: pin to `linuxPackages` until the driver
  catches up.
- `modules/home/tidal.nix` pulls in GHC + SuperCollider (~1–2GB
  closure) for [TidalCycles](https://tidalcycles.org/) live-coding.
  Drop the import from `modules/home/default.nix` if you don't use it.
- `make profile` is a no-op on `thinkpad` / `macbook` — those tools
  already ship via home-manager. The `profile/` output is for using
  this flake on non-NixOS Linux machines (`nix profile install .#profile`).
