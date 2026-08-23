{ ... }:

{
  networking.hostName = "thinkbook14";

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  imports = [
    ../../modules/nixos/roles/laptop.nix
    ../../modules/nixos/desktop/gdm-gnome.nix
    ./hardware-configuration.nix
  ];
}
