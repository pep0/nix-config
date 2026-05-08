# nix-config

:snowflake: Personal [NixOS](https://nixos.org/) configuration for
multiple machines. Built on [Flakes](https://nixos.wiki/wiki/Flakes),
[Home Manager](https://github.com/nix-community/home-manager),
[Stylix](https://github.com/danth/stylix), and
[sops-nix](https://github.com/Mic92/sops-nix).

## Features

- **Window Managers**: Hyprland and niri (scrollable-tiling), picked
  at the `greetd` + `tuigreet` TTY login. Both themed Tokyo Night
  via Stylix.
- **Terminal**: Kitty + Nushell with Starship prompt, Carapace
  completions, direnv integration
- **Editor**: Helix with `nil` for Nix LSP
- **Development**: Rust toolchain (rust-overlay), `nh` for rebuilds,
  `devenv` for project shells
- **Tools**: Claude Code, Lazygit, Yazi, ripgrep, fd, bat, jq, btop,
  nvtop, fastfetch
- **Theming**: Stylix-driven, single source of truth
- **Security**: Secure Boot via Lanzaboote (where supported), full-disk
  encryption (LUKS), AppArmor, auditd
- **Secrets**: sops-nix with age encryption

## Hardware

The flake exposes one entry per machine:

| Host      | Model                                       | Notes                                      |
| :-------- | :------------------------------------------ | :----------------------------------------- |
| `default` | ThinkPad P14s Gen 5 (Intel)                 | Lanzaboote Secure Boot, NVIDIA PRIME       |
| `macbook` | MacBook Pro Mid 2014, 13" (MacBookPro11,1)  | Broadcom STA Wi-Fi, mbpfan, no Lanzaboote  |

`nh os switch .` picks the entry matching the current hostname; pass
`.#<name>` to target one explicitly.

## Prerequisites

- Git
- [nh](https://github.com/viperML/nh) (NixOS helper) — installed by
  the flake on first rebuild; bootstrap with `nix-shell -p nh` or use
  stock `nixos-rebuild` for the very first switch
- [NixOS](https://nixos.org/) installed (only for the system part —
  the user profile works on any Linux with Nix)

For a fresh install or migrating from a different config, see
[INSTALL.md](INSTALL.md).

## Directory Structure

- `flake.nix` — outputs and the `mkSystem` helper that wires each host
- `flake.lock` — pinned input versions
- `hosts/default/` — ThinkPad-specific: PRIME, Lanzaboote
- `hosts/macbook/` — MacBook-specific: broadcom-sta, mbpfan
- `modules/system/` — generic system modules (boot, networking,
  secrets, stylix, …)
- `modules/desktop/` — Hyprland + login manager + portals
- `modules/home/` — home-manager modules (shell, git, hyprland)
- `modules/theme/` — color palette aliases for places stylix can't
  reach (e.g. ad-hoc Hyprland border gradients)
- `profile/` — user-level package set (installable on any Nix-enabled
  Linux)
- `secrets/` — sops-encrypted secret files (encrypted blobs are safe
  to commit)
- `Makefile` — convenience wrappers
- [INSTALL.md](INSTALL.md) — first-time install / migration walkthrough
- [SECUREBOOT.md](SECUREBOOT.md) — Lanzaboote enrolment walkthrough
- [SECRETS.md](SECRETS.md) — sops-nix bootstrap walkthrough

## Installation

See [INSTALL.md](INSTALL.md). Once you're already on NixOS:

1. Clone this repo
1. Drop your `hardware-configuration.nix` into `hosts/<name>/`
1. Run `make system` to apply the system config
1. Run `make home` to apply home-manager

## Update

1. Run `make update` to refresh `flake.lock`
1. Run `make system` to rebuild the system against the new lock
1. Run `make home` to do the same for home-manager

## Maintenance

1. Run `make diff` to dry-build and see what would change without
   applying
1. Run `make rollback` to revert to the previous system generation
1. Run `make clean` to garbage-collect (keeps last 5 generations and
   everything from the last 14 days)

## Caveats

- `modules/system/boot.nix` uses `pkgs.linuxPackages_latest`.
  Bleeding-edge kernels occasionally break the out-of-tree NVIDIA
  driver — if a rebuild fails on the kernel module, fall back to
  `linuxPackages` (LTS) until the driver catches up.

## Colors

The whole setup follows the
[Tokyo Night](https://github.com/folke/tokyonight.nvim) palette via
Stylix. Swap `base16Scheme` in `modules/system/stylix.nix` to change
it; the manual aliases in `modules/theme/default.nix` should be kept
in lockstep.

| Purpose    | Color     |
| :--------- | :-------- |
| Foreground | `#c0caf5` |
| Background | `#1a1b26` |
| Primary    | `#bb9af7` |
| Warning    | `#e0af68` |
| Danger     | `#f7768e` |

## Key Bindings

Shared between both compositors:

| Function                      | Keys                            |
| :---------------------------- | :------------------------------ |
| Open Terminal                 | `Super + Q`                     |
| Kill Active Window            | `Super + C`                     |
| Open App Launcher             | `Super + R`                     |
| Exit Compositor               | `Super + M`                     |
| Focus Window                  | `Super + [Arrow]`               |
| Switch to Workspace           | `Super + [1-4]`                 |
| Move Window to Workspace      | `Super + Shift + [1-4]`         |

niri-only (scrollable-tiling specifics):

| Function                      | Keys                            |
| :---------------------------- | :------------------------------ |
| Move Column / Window          | `Super + Shift + [Arrow]`       |
| Cycle Preset Column Widths    | `Super + W`                     |
| Maximize Column               | `Super + F`                     |
| Fullscreen Window             | `Super + Shift + F`             |
| Take Screenshot               | `Print`                         |
| Lock Screen                   | `Super + Ctrl + Q`              |

Hyprland-only (mouse interactions):

| Function                      | Keys                            |
| :---------------------------- | :------------------------------ |
| Move Window                   | `Super + Left Mouse Button`     |
| Resize Window                 | `Super + Right Mouse Button`    |

## Terminal Commands

| Function                  | Command           |
| :------------------------ | :---------------- |
| Open Agentic Coding Tool  | `a` (Claude Code) |
| Open Text Editor          | `e` (Helix)       |
| Open File Manager         | `f` (Yazi)        |
| Open Git Browser          | `g` (Lazygit)     |
| List Directory Contents   | `l` (ls)          |
| Open System Monitor       | `m` (btop)        |
| Open File                 | `o` (xdg-open)    |
| Open Task Manager         | `t` (Taskwarrior) |
