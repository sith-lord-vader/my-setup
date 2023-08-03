{
  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    home-manager = { url = "github:nix-community/home-manager"; };
  };
  outputs = { self, nixpkgs, vscode-server, home-manager, ... }:
    let
    in {
      nixosConfigurations.death-star = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./configuration.nix
        ];
        specialArgs = { inherit home-manager; inherit vscode-server; };
      };
    };
}
