# nix-config

Multi-host NixOS configuration. The flake exposes:

- `nixosConfigurations.default` — ThinkPad P14s Gen 5 (Intel), with
  Lanzaboote Secure Boot and PRIME-offload NVIDIA dGPU.
- `nixosConfigurations.macbook` — MacBook Pro Mid 2014, 13" Retina
  (MacBookPro11,1), Haswell + Intel Iris 5100 only.
- `packages.x86_64-linux.profile` — a user-level toolset, installable
  on any Linux machine with the Nix package manager.

`nh os switch .` picks the entry whose name matches the current
hostname; pass `.#<name>` to target one explicitly.

## Edit before installing

- `hosts/<name>/default.nix` — `networking.hostName`.
- `modules/system/users.nix` — username (also update `flake.nix`'s
  `home-manager.users.pep0` and `modules/home/default.nix`'s
  `home.username` / `homeDirectory` to match).
- `modules/system/nix.nix` — `programs.nh.flake` path (the place you'll
  clone this repo to).
- `modules/system/locale.nix` — timezone.
- `modules/home/git.nix` — name and email.
- `modules/system/stylix.nix` — replace the placeholder wallpaper with
  your own image; pick a different `base16Scheme` if you don't want
  Tokyo Night.
- `.sops.yaml` — replace the placeholder age public key with one you
  generated. See `SECRETS.md` for the bootstrap.
- `hosts/<name>/hardware-configuration.nix` — generated with
  `nixos-generate-config --root /mnt` during install. Drop it in the
  host directory you're targeting (`hosts/default/` for the ThinkPad,
  `hosts/macbook/` for the MacBook).
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
   `hardware-configuration.nix` into the target `hosts/<name>/`, then:
   ```
   nixos-install --flake /mnt/etc/nixos#<name>     # default | macbook
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

- `flake.nix` — outputs and the `mkSystem` helper that wires each host.
- `hosts/default/` — ThinkPad P14s Gen 5: NVIDIA PRIME, Lanzaboote.
- `hosts/macbook/` — MacBook Pro Mid 2014: broadcom-sta Wi-Fi, mbpfan,
  no Lanzaboote (Apple firmware doesn't enroll user keys).
- `modules/system/` — generic system modules (boot, networking,
  secureboot, security, …) shared across hosts.
- `modules/desktop/` — Hyprland + login manager + portals. Hardware-
  specific GPU env vars live in the host file, not here.
- `modules/home/` — home-manager modules for user dotfiles.
- `modules/theme/` — explicit color palette referenced where stylix's
  scheme can't reach (e.g. ad-hoc Hyprland border gradients). Stylix
  is the primary theme source — see `modules/system/stylix.nix`.
- `profile/` — the user-level package set.
- `secrets/` — sops-encrypted secret files (the encrypted blobs are
  safe to commit).
- `Makefile` — workflow wrappers.
- `SECUREBOOT.md` — Lanzaboote setup walkthrough.
- `SECRETS.md` — sops-nix bootstrap walkthrough.

## Caveats

- `modules/system/boot.nix` uses `pkgs.linuxPackages_latest`. Bleeding
  -edge kernels occasionally break the out-of-tree NVIDIA driver — if
  a rebuild fails on the kernel module, fall back to `linuxPackages`
  (LTS) until the driver catches up.

To add a third machine: copy a `hosts/<name>/` directory, swap the
nixos-hardware module + GPU bits in its `default.nix`, then add one
line to `nixosConfigurations` in `flake.nix`.
