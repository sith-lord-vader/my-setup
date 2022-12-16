{
  inputs.nixpkgs = { url = "github:nixos/nixpkgs/nixos-22.11"; };
  inputs.test = { url = "github:abhishekadhikari23/nix-pkg-module-boilerplate"; };
  outputs = { self, nixpkgs, test }:
    let
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ test.nixosModules.module_name ./configuration.nix ];
        specialArgs = { inherit test; };
      };
    };
}
