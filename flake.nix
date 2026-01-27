{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # contains Linux kernel 5.15.90 for mouse freeze
    nixpkgs-kernel-fix.url = "github:nixos/nixpkgs/0218941ea68b4c625533bead7bbb94ccce52dceb";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-kernel-fix,
      home-manager,
    }:
    {
      lib = rec {
        deps = system: {
          inputs = inputs;
          stable = makePkgs system nixpkgs;
          unstable = makePkgs system nixpkgs-unstable;
          kernel-fix = makePkgs system nixpkgs-kernel-fix;
        };
        makePkgs =
          system: pkgs:
          import pkgs {
            system = system;
            overlays = [ (final: prev: deps final.system) ];
            config.allowUnfree = true; # forgive me Stallman senpai
          };
        makeHome =
          {
            user,
            homeDirectory,
            host,
            system,
            stateVersion,
          }:
          home-manager.lib.homeManagerConfiguration {
            pkgs = makePkgs system nixpkgs;
            modules = [
              ./${host}/home.nix
              {
                home = {
                  username = user;
                  homeDirectory = homeDirectory;
                  stateVersion = stateVersion;
                };
              }
            ];
          };
        makeSystem =
          { host, system }:
          nixpkgs.lib.nixosSystem {
            system = system;
            specialArgs = deps system;
            modules = [
              {
                networking.hostName = host;
                nix = {
                  registry.nixpkgs.flake = nixpkgs;
                  registry.unstable.flake = nixpkgs-unstable;
                  nixPath = [ "nixpkgs=${nixpkgs}" ];
                };
              }
              ./${host}/system.nix
              ./${host}/hardware.nix
            ];
          };
      };
      homeConfigurations = {
        oxygen = self.lib.makeHome {
          user = "felix";
          homeDirectory = "/home/felix";
          host = "oxygen";
          system = "x86_64-linux";
          stateVersion = "22.11";
        };
      };
      nixosConfigurations = {
        oxygen = self.lib.makeSystem {
          host = "oxygen";
          system = "x86_64-linux";
        };
      };
    };
}
