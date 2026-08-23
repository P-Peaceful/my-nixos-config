{
  description = "NixOS 配置仓库阶段 5：GDM 与精简 GNOME 恢复会话";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

      nixosConfigurations.thinkbook14 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./modules/nixos/core
          ./hosts/thinkbook14
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.wenzhengcheng = import ./home/wenzhengcheng;
            };
          }
        ];
      };
    };
}
