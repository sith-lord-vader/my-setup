{
  inputs.nixpkgs = { url = "github:nixos/nixpkgs/nixos-22.11"; };
  inputs.test = { url = "github:abhishekadhikari23/nix-pkg-module-boilerplate"; };
  inputs.systemd-controller = { url = "git+ssh://git@tree.mn/autoopt-hadoop-devops/remote-systemd-controller.git"; };
  inputs.elasticsearch = { url = "path:/home/xpert/Work/es8-deploy"; };
  inputs.jupyterhub1 = { url = "path:/home/xpert/Work/jupyterhub"; };
  inputs.vscode-server.url = "github:msteen/nixos-vscode-server";
  outputs = { self, nixpkgs, test, systemd-controller, elasticsearch, vscode-server, jupyterhub1 }:
    let
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          test.nixosModules.module_name 
          elasticsearch.nixosModules.kibana8 
          systemd-controller.nixosModules.darth-vader 
          systemd-controller.nixosModules.stormtrooper 
          # vscode-server.nixosModule
          # ({ config, pkgs, ... }: {
          #   services.vscode-server.enable = true;
          #   # services.vscode-server.enableFHS = true;
          #   services.vscode-server.extraRuntimeDependencies = with pkgs; [
          #     curl
          #     git
          #   ];
          # })
          ./configuration.nix
        ];
        specialArgs = { inherit test; inherit elasticsearch; inherit jupyterhub1; };
      };
    };
}
