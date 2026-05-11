{ pkgs, ... }:
{
  # CLI tools installed into the home-manager profile so they show up
  # on every `make system` rebuild. `programs.<name>.enable` is used
  # where home-manager has a module — that gets stylix theming and
  # declarative config; plain `home.packages` for the rest.
  #
  # The `profile/` flake output mirrors this list for non-NixOS hosts
  # (`nix profile install .#profile`); the two lists are kept in sync
  # by hand. If you only run NixOS, you can ignore `make profile`.

  programs.helix = {
    enable = true;
    defaultEditor = true;
  };
  programs.yazi.enable = true;
  programs.btop.enable = true;
  programs.bat.enable = true;
  programs.fastfetch.enable = true;

  home.packages = with pkgs; [
    # search / inspection
    ripgrep
    fd
    jq
    ncdu
    nvtopPackages.full

    # nix dev
    nixpkgs-fmt
    nil                    # nix LSP

    # rust toolchain (stable nixpkgs versions)
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy

    # ai / dev shells
    claude-code
    devenv
  ];
}
