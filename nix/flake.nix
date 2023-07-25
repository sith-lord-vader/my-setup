{
  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    vscode-server.url = "github:msteen/nixos-vscode-server";
    home-manager = { url = "github:nix-community/home-manager"; };
  };
  outputs = { self, nixpkgs, home-manager, ... }:
    let
    in {
      nixosConfigurations.death-star = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./configuration.nix
        ];
        specialArgs = { inherit home-manager; };
      };
    };
}
