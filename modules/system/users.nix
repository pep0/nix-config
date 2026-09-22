{ pkgs, username, ... }:
{
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "wheel"            # sudo
      "networkmanager"   # nmcli without root
      "video"            # backlight, GPU
      "audio"            # ALSA/Pipewire device access
      "dialout"          # serial devices (/dev/ttyACM*) — Chrysalis/keyboard flashing
      "kvm"              # /dev/kvm — hardware-accelerated VMs/emulators
    ];
    shell = pkgs.nushell;

    # Explicit subuid/subgid range for rootless Podman/Buildah. NixOS would
    # otherwise auto-allocate one (autoSubUidGidRange defaults to true when
    # these are unset), but that wasn't landing in /etc/subuid in practice —
    # spelling it out here makes it deterministic and easy to verify.
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };

  # Set an initial password with `passwd` after first boot.
  # Don't ship a real password in source control.
}
