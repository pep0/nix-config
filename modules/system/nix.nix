{ pkgs, ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # Trust the wheel group to use binary caches and substituters they
    # specify. Important for things like cachix.
    trusted-users = [ "root" "@wheel" ];

    # Substituters: where Nix downloads prebuilt packages from.
    # cache.nixos.org is included by default.
    substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];

    auto-optimise-store = true;
  };

  # nh handles GC instead of nix.gc.automatic — they conflict if both
  # are enabled. Keep last 5 generations and everything from last 14d.
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 14d --keep 5";
    flake = "/home/tuna/nix-config";  # set NH_FLAKE so `nh os switch` works without args
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Bare minimum so a fresh install isn't unusable. Most tools live
    # in the user profile, not here.
    git
    vim
    curl
    wget
  ];
}
