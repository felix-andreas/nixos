{
  description = "Developer Machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # used by felix, contains Linux kernel 5.15.90 for mouse freeze
    nixpkgs-kernel-fix.url = "github:nixos/nixpkgs/0218941ea68b4c625533bead7bbb94ccce52dceb";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , nixpkgs-unstable
    , nixpkgs-kernel-fix
    , home-manager
    }:
    let
      deps = system: {
        inherit inputs;
        stable = makePkgs system nixpkgs;
        unstable = makePkgs system nixpkgs-unstable;
        kernel-fix = makePkgs system nixpkgs-kernel-fix;
      };
      makePkgs = system: pkgs:
        import pkgs {
          inherit system;
          overlays = [ (final: prev: deps final.system) ];
          config.allowUnfree = true; # forgive me Stallman senpai
        };
      makeHome = { user, host, system ? "x86_64-linux" }:
        let
          pkgs = makePkgs system nixpkgs;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./${host}/home.nix
            {
              home = {
                username = "${user}";
                homeDirectory = with pkgs;
                  if stdenv.isLinux then
                    "/home/${user}"
                  else if stdenv.isDarwin then
                    "/Users/${user}"
                  else throw "Unknown OS";
                stateVersion = "22.11";
              };
            }
          ];
        };
      makeSystem = { host }:
        let
          system = "x86_64-linux";
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
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
    in
    {
      homeConfigurations = {
        oxygen = makeHome { user = "felix"; host = "oxygen"; };
      };
      nixosConfigurations = {
        oxygen = makeSystem { host = "oxygen"; };
      };
    };
}
