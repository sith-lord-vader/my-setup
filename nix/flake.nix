{
  inputs.nixpkgs = { url = "github:nixos/nixpkgs/nixos-22.11"; };
  inputs.test = { url = "github:abhishekadhikari23/nix-pkg-module-boilerplate"; };
  inputs.systemd-controller = { url = "git+ssh://git@tree.mn/autoopt-hadoop-devops/remote-systemd-controller.git"; };
  inputs.elasticsearch = { url = "path:/home/xpert/Work/es8-deploy"; };
  outputs = { self, nixpkgs, test, systemd-controller, elasticsearch }:
    let
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ test.nixosModules.module_name systemd-controller.nixosModules.darth-vader systemd-controller.nixosModules.stormtrooper ./configuration.nix ];
        specialArgs = { inherit test; inherit elasticsearch; };
      };
    };
}
