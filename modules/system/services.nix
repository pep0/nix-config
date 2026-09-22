{ pkgs, ... }:
{
  # OpenSSH daemon, reachable over tailscale only: `openFirewall` would
  # otherwise punch 22 through on every interface, including whatever
  # café Wi-Fi the laptop is on. tailscale.nix trusts tailscale0, so the
  # mesh still reaches sshd.
  #
  # Keys only — passwords are the thing worth brute-forcing, and every
  # host that needs in already has a key.
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Periodic SSD trim (weekly by default).
  services.fstrim.enable = true;

  # Battery / AC events. poweralertd in the user profile subscribes for
  # low-battery notifications; without upower nothing would publish them.
  services.upower.enable = true;

  # Don't suspend the moment the power button is tapped — route it
  # through the powermenu instead (Mod+P).
  services.logind.settings.Login.HandlePowerKey = "ignore";

  # Don't wait the systemd default 90s on a hanging unit at shutdown.
  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";

  # Keyboardio/Kaleidoscope keyboards (Atreus, Model01, Model100,
  # Preonic): stable /dev symlinks + non-root access for flashing
  # firmware via Chrysalis / the Kaleidoscope tooling.
  #
  # Must be installed via services.udev.packages (not extraRules): the
  # uaccess tag is only honored for rules that sort before systemd's
  # 73-seat-late.rules, and extraRules always lands in 99-local.rules.
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "kaleidoscope-udev-rules";
      destination = "/etc/udev/rules.d/50-kaleidoscope.rules";
      text = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2303", SYMLINK+="Atreus",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2302", SYMLINK+="Atreus",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2301", SYMLINK+="Model01",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2300", SYMLINK+="Model01",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3496", ATTRS{idProduct}=="0006", SYMLINK+="Model100",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3496", ATTRS{idProduct}=="0005", SYMLINK+="Model100",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3496", ATTRS{idProduct}=="00a1", SYMLINK+="Preonic",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3496", ATTRS{idProduct}=="00a3", SYMLINK+="Preonic",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3496", ATTRS{idProduct}=="00a0", SYMLINK+="Preonic",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
      '';
    })
  ];
}
