{
  inputs.bulla = { url = "git+ssh://git@tree.mn/autoopt-hadoop-devops/remote-systemd-controller"; };
  outputs = { self, nixpkgs, bulla }:
   let 
    in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
      specialArgs = { inherit bulla; };
    };
  };
}
