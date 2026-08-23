{ pkgs, ... }:

{
  # 使用 NixOS 官方 Niri 模块注册 GDM 会话、门户和 GNOME Keyring 集成。
  programs.niri = {
    enable = true;
    useNautilus = true;
  };

  # 上游默认 Niri 配置依赖这些运行时程序；Noctalia 和 Waybar 留到后续阶段。
  environment.systemPackages = with pkgs; [
    alacritty
    fuzzel
    xwayland-satellite
  ];
}
