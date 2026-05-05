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

    # Hardware quirks for the ThinkPad P14s Gen 5 (Intel).
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Use the flake's Hyprland — the devs explicitly recommend this over
    # the nixpkgs version when bug-hunting.
    hyprland.url = "github:hyprwm/Hyprland";

    # Lanzaboote: Secure Boot for NixOS. Pin to a release tag.
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix: one base16 scheme + font set propagated everywhere
    # (system, home-manager, hyprland, terminals, GTK, Qt, ...).
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, hyprland, lanzaboote, rust-overlay, stylix, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
        config.allowUnfree = true;
      };
    in
    {
      # ---------------------------------------------------------------
      # System: `nh os switch .` (or sudo nixos-rebuild switch --flake .#default)
      # ---------------------------------------------------------------
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/default
          # ThinkPad P14s Gen 5 Intel: power management, ACPI, etc.
          nixos-hardware.nixosModules.lenovo-thinkpad-p14s-intel-gen5
          lanzaboote.nixosModules.lanzaboote

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.pep0 = import ./modules/home;
          }
        ];
      };

      # ---------------------------------------------------------------
      # User profile: `nix profile install .#profile`
      # ---------------------------------------------------------------
      packages.${system}.profile = import ./profile { inherit pkgs; };
      packages.${system}.default = self.packages.${system}.profile;
    };
}
