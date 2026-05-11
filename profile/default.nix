{ pkgs }:

# Portable user-level toolset for non-NixOS machines that have Nix
# installed (`nix profile install .#profile`). On NixOS hosts in this
# flake, home-manager (modules/home/cli-tools.nix) already installs
# the same tools — running `make profile` there is redundant.
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

    # Rust toolchain. Stable nixpkgs versions; for bleeding-edge
    # toolchains in a project, use a per-project devenv/flake.
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy

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
