{
  description = "NixOS system configuration + user profile";

  inputs = {
    # Stable channel. Lanzaboote 1.0+ supports it, package churn is
    # smaller than unstable, and the binary cache hit rate is higher.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware quirks for ThinkPads, MacBooks, etc. Per-host modules
    # are imported from the relevant hosts/<name>/default.nix file.
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Lanzaboote: Secure Boot for NixOS. Pin to a release tag.
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix: one base16 scheme + font set propagated everywhere
    # (system, home-manager, terminals, GTK, Qt, ...).
    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix: declarative, encrypted secrets. See SECRETS.md.
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # niri-flake: scrollable-tiling Wayland compositor.
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # claude-code: auto-updated hourly, always tracks the latest release.
    claude-code-nix.url = "github:sadjow/claude-code-nix";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, lanzaboote, stylix, sops-nix, niri, claude-code-nix, ... }@inputs:
    let
      system = "x86_64-linux";

      # Single source of truth for the few values that get sprinkled
      # across host + home modules.
      username = "pep0";
      stateVersion = "25.11";

      # Used only for the user `profile` output. System pkgs are
      # configured per-host via `nixpkgs.config` in modules/system/nix.nix.
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # One entry per host. Hardware-specific modules live inside the
      # host file (hosts/<name>/default.nix); this helper just stitches
      # in home-manager + the shared specialArgs.
      mkSystem = hostPath: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username stateVersion; };
        modules = [
          hostPath
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ claude-code-nix.overlays.default ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-bak";
            home-manager.extraSpecialArgs = { inherit inputs username stateVersion; };
            home-manager.users.${username} = import ./modules/home;
          }
        ];
      };
    in
    {
      # ---------------------------------------------------------------
      # Systems. Build with `nh os switch .` (uses the current hostname)
      # or `sudo nixos-rebuild switch --flake .#<name>` to target one
      # explicitly.
      # ---------------------------------------------------------------
      nixosConfigurations = {
        thinkpad = mkSystem ./hosts/thinkpad;   # ThinkPad P14s Gen 5 (Intel)
        macbook  = mkSystem ./hosts/macbook;    # MacBook Pro Mid 2014, 13" (MacBookPro11,1)
      };

      # ---------------------------------------------------------------
      # User profile: `nix profile install .#profile`
      # ---------------------------------------------------------------
      packages.${system} = {
        profile = import ./profile { inherit pkgs; };
        default = self.packages.${system}.profile;
      };
    };
}
