{ pkgs }:

pkgs.buildEnv {
  name = "user-profile";
  paths = with pkgs; [
    # Editor and shell
    helix
    nushell
    starship
    carapace

    # Git tooling
    lazygit
    delta

    # Rust toolchain with rust-analyzer (needs the rust-overlay applied
    # to `pkgs` in flake.nix)
    (rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" "rust-analyzer" ];
    })

    # System inspection
    btop
    fastfetch
    ncdu
    nvtopPackages.full   # GPU usage for both Intel + Nvidia in one TUI

    # File / terminal utilities
    yazi
    ripgrep
    fd
    bat
    jq

    # Nix dev
    nh             # nicer nixos-rebuild wrapper
    nixpkgs-fmt
    nil            # nix LSP

    # Misc
    devenv
    direnv
  ];
}
