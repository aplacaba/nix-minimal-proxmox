{
  description = "Minimal nixos w/ caddy";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    deploy-rs.url = "github:serokell/deploy-rs";
    disko.url = "github:nix-community/disko";
  };

  outputs = { self, nixpkgs, disko, deploy-rs, ... }@inputs: {
    nixosConfigurations.nxm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        disko.nixosModules.disko
        ./disko-config.nix
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };

    deploy.nodes.nxm = {
      hostname = "192.168.254.113";
      sshUser = "root";
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nxm;
      };
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
