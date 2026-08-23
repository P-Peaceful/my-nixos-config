{ pkgs, ... }:

{
  # GDM 是本阶段唯一的显示管理器，登录必须由用户输入密码完成。
  services.displayManager.gdm.enable = true;
  services.displayManager.autoLogin.enable = false;

  # GNOME 作为独立的图形恢复会话，不依赖后续桌面外壳。
  services.desktopManager.gnome.enable = true;
  services.gnome.core-apps.enable = false;

  # core-shell 仍由 GNOME 桌面模块提供控制中心等基础组件；核心应用集合
  # 关闭后，显式保留文件管理器作为恢复会话的基本操作入口。
  environment.systemPackages = [ pkgs.nautilus ];

  # GNOME 默认会启用 IBus；输入法由 Home Manager 的 Fcitx5 模块独占。
  i18n.inputMethod.enable = false;

  # 指纹、Bolt 和打印服务的关闭合同由 laptop 角色持有，本模块不重复声明配置所有权。
}
