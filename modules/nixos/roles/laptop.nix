{ ... }:

{
  networking.networkmanager.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  security.polkit.enable = true;
  services.fwupd.enable = true;

  # 这些设备授权服务不属于通用笔记本角色的职责范围。
  services.fprintd.enable = false;
  services.printing.enable = false;
  services.hardware.bolt.enable = false;
}
