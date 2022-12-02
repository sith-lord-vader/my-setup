{
  inputs.nixpkgs = { url = "github:nixos/nixpkgs/nixos-22.05"; };
  inputs.bulla = { url = "git+ssh://git@tree.mn/autoopt-hadoop-devops/remote-systemd-controller?ref=master"; };
  inputs.gitit-wiki = { url = "path:/home/xpert/Work/gitit-config"; };
  inputs.test = { url = "path:/home/xpert/Work/nix-pkg-module-boilerplate"; };
  outputs = { self, nixpkgs, bulla, gitit-wiki, test }:
    let
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ bulla.nixosModules.stormtrooper gitit-wiki.nixosModules.gitit-wiki test.nixosModules.module_name ./configuration.nix ];
        specialArgs = { inherit bulla; inherit gitit-wiki; inherit test; };
      };
    };
}
