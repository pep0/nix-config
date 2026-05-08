{ pkgs, inputs, ... }:
{
  # zen-browser comes from a flake (not in nixpkgs yet). Bound to
  # `Super + B` in both compositor configs.
  home.packages = [
    inputs.zen-browser.packages.${pkgs.system}.default
  ];
}
