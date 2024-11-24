{
  description = "KooL's NixOS-Hyprland";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    distro-grub-themes.url = "github:AdisonCavani/distro-grub-themes";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    # Keep both hostnames - original and new
    currentHost = "Thisbe";
    newHost = "JaKooLit";
    # Keep both usernames - original and new
    currentUser = "bimmer";
    newUser = "alice";

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in {
    nixosConfigurations = {
      # Keep your original configuration
      "${currentHost}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          username = currentUser;
          host = currentHost;
        };
        modules = [
          ./hosts/${currentHost}/config.nix
        ];
      };

      # Add the new configuration
      "${newHost}" = nixpkgs.lib.nixosSystem rec {
        specialArgs = {
          inherit system;
          inherit inputs;
          username = newUser;
          host = newHost;
        };
        modules = [
          ./hosts/${newHost}/config.nix
          inputs.distro-grub-themes.nixosModules.${system}.default
        ];
      };
    };
  };
}
