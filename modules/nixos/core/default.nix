{ ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # 保持 Nixpkgs 的默认策略，禁止使用非自由软件。
  nixpkgs.config.allowUnfree = false;

  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
  };

  services.xserver.xkb.layout = "us";

  system.stateVersion = "26.05";

  users.users.wenzhengcheng = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };
}
