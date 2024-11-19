{
  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    nixpkgs-mirror = { url = "git+file:///home/xpert/work/nixpkgs-mirror?ref=es8"; };
    cloudflare-warp = { url = "git+file:///home/xpert/work/cloudflare-warp-nix"; };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    home-manager = { url = "github:nix-community/home-manager"; };
    certify-rebellion = { url = "git+file:///home/xpert/work/certify-rebellion"; };
  };
  outputs = { self, nixpkgs, vscode-server, home-manager, nixpkgs-mirror, certify-rebellion, cloudflare-warp, ... }:
    let
      pkgs-extras = import nixpkgs-mirror {
        system = "x86_64-linux";
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ "electron" "electron-27.3.11" ];
      }; 
    in {
      nixosConfigurations.death-star = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
        specialArgs = { inherit home-manager; inherit vscode-server; inherit pkgs-extras; inherit certify-rebellion; inherit cloudflare-warp; };
      };
    };
}
