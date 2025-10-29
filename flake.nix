{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.url = "github:nix-community/home-manager/release-25.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { nixpkgs, nixpkgs-unstable, disko, home-manager, ... }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    nixosConfigurations = {
      ax52 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./hosts/ax52/configuration.nix
          # Make nixpkgs-unstable available to our configuration
          ({ pkgs, ... }: {
            nixpkgs.overlays = [
              (final: prev: {
                github-runner-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux.github-runner;
              })
            ];
          })
        ];
      };
    };
  };
}
