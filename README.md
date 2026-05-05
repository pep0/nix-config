# nix-config

Single-repo NixOS configuration for a ThinkPad P14s Gen 5 (Intel).
The flake exposes two outputs:

- `nixosConfigurations.default` — the system, built with `nh os switch`.
- `packages.x86_64-linux.profile` — a user-level toolset, installable
  on any Linux machine with the Nix package manager.

## Edit before installing

- `hosts/default/default.nix` — `networking.hostName`.
- `modules/system/users.nix` — username (also update `flake.nix`'s
  `home-manager.users.tuna` and `modules/home/default.nix`'s
  `home.username` / `homeDirectory` to match).
- `modules/system/nix.nix` — `programs.nh.flake` path (the place you'll
  clone this repo to).
- `modules/system/locale.nix` — timezone.
- `modules/home/git.nix` — name and email.
- `hosts/default/hardware-configuration.nix` — generated with
  `nixos-generate-config --root /mnt` during install. Drop it in
  `hosts/default/`.
- LUKS in `modules/system/boot.nix` — uncomment and fill the UUID, or
  delete and let `hardware-configuration.nix` own it.

## First-time install

1. Boot the NixOS installer ISO (use the unstable image — this config
   tracks unstable for Lanzaboote support).
2. Partition and format. For LUKS:
   ```
   cryptsetup luksFormat /dev/nvme0n1p2
   cryptsetup open /dev/nvme0n1p2 cryptroot
   mkfs.ext4 -L nixos /dev/mapper/cryptroot
   mount /dev/disk/by-label/nixos /mnt
   mkfs.fat -F32 -n boot /dev/nvme0n1p1
   mkdir -p /mnt/boot && mount /dev/disk/by-label/boot /mnt/boot
   ```
3. Generate hardware config:
   ```
   nixos-generate-config --root /mnt
   ```
4. Clone this repo into `/mnt/etc/nixos`, copy the generated
   `hardware-configuration.nix` into `hosts/default/`, then:
   ```
   nixos-install --flake /mnt/etc/nixos#default
   ```
5. Reboot, log in, set a password.
6. (Optional but recommended) Follow `SECUREBOOT.md` to enable
   Lanzaboote / Secure Boot.

## Day-to-day

```
make system     # rebuild + switch the OS (nh os switch .)
make home       # rebuild + switch home-manager
make profile    # install/upgrade the user profile
make update     # update flake.lock
make diff       # dry-build, show what would change
make clean      # garbage-collect old generations
make rollback   # roll system back one generation
```

`make` with no args lists everything.

## Layout

- `flake.nix` — both outputs.
- `hosts/default/` — per-machine system config + hardware-configuration.
- `modules/system/` — system modules (boot, networking, secureboot,
  security, …).
- `modules/desktop/` — Hyprland + login manager + portals + GPU env.
- `modules/home/` — home-manager modules for user dotfiles.
- `modules/theme/` — central color palette + font choices.
- `profile/` — the user-level package set.
- `Makefile` — workflow wrappers.
- `SECUREBOOT.md` — Lanzaboote setup walkthrough.

To add a second machine: copy `hosts/default/` to `hosts/laptop/`,
adjust hardware-configuration, and add a second entry to
`nixosConfigurations` in `flake.nix`.
