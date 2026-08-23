{ pkgs, ... }:

{
  imports = [
    ../core
    ../../modules/home/noctalia.nix
  ];

  home.stateVersion = "26.05";

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-rime ];
  };
}
