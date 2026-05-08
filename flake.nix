{
  description = "NixOS system configuration + user profile";

  inputs = {
    # Lanzaboote currently only supports nixos-unstable, so the system
    # tracks unstable. If you want to peg to a release channel later,
    # accept that you'll lose Secure Boot until lanzaboote backports.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware quirks for ThinkPads, MacBooks, etc. Per-host modules
    # are imported from the relevant hosts/<name>/default.nix file.
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Use the flake's Hyprland — the devs explicitly recommend this over
    # the nixpkgs version when bug-hunting.
    hyprland.url = "github:hyprwm/Hyprland";

    # Lanzaboote: Secure Boot for NixOS. Pin to a release tag.
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix: one base16 scheme + font set propagated everywhere
    # (system, home-manager, hyprland, terminals, GTK, Qt, ...).
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix: declarative, encrypted secrets. See SECRETS.md.
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # niri-flake: scrollable-tiling Wayland compositor. Coexists with
    # Hyprland — both are listed at the greetd login picker.
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zen-browser: Firefox fork with a modern UI. Not yet in nixpkgs;
    # this flake ships pinned binaries.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, hyprland, lanzaboote, stylix, sops-nix, niri, zen-browser, ... }@inputs:
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
        # Moomin twins: Vifslan (the larger one) is the ThinkPad,
        # Tofslan (the smaller, older one) is the MacBook.
        vifslan = mkSystem ./hosts/vifslan;   # ThinkPad P14s Gen 5 (Intel)
        tofslan = mkSystem ./hosts/tofslan;   # MacBook Pro Mid 2014, 13" (MacBookPro11,1)
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
