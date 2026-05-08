# nix-config

Personal [NixOS](https://nixos.org/) flake for two machines.

| Host      | Target                                      |
| :-------- | :------------------------------------------ |
| `default` | ThinkPad P14s Gen 5 (Intel)                 |
| `macbook` | MacBook Pro Mid 2014, 13" (MacBookPro11,1)  |

Hyprland and niri coexist as login sessions (picked at greetd), themed
Tokyo Night via Stylix. Secrets via sops-nix; Secure Boot via
Lanzaboote on the ThinkPad.

## Layout

- `flake.nix` — outputs and the `mkSystem` helper
- `hosts/<name>/` — per-machine config + hardware
- `modules/system/` — shared system modules
- `modules/desktop/` — generic Wayland infra + Hyprland and niri
- `modules/home/` — home-manager modules
- `profile/` — user-level package set, installable on any Nix-enabled Linux

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
- Secrets bootstrap: [SECRETS.md](SECRETS.md)

## Note

`modules/system/boot.nix` uses `pkgs.linuxPackages_latest`. If a
rebuild fails on the NVIDIA kernel module after a kernel bump, fall
back to `linuxPackages` (LTS).
