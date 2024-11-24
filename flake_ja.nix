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
    thisbeUser = "bimmer";
    jakoolUser = "alice";
    hostName = "Thisbe";
    newHost = "JaKooLit";

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in {
    nixosConfigurations = {
      "${hostName}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          username = thisbeUser;
          host = hostName;
        };
        modules = [
          ./hosts/${hostName}/config.nix
        ];
      };

      "${newHost}" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit system;
          inherit inputs;
          username = jakoolUser;  # alice is now the primary user
          secondUser = thisbeUser;  # bimmer becomes the second user
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

