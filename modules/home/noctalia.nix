{ pkgs, ... }:

let
  # 官方服务绑定通用 Wayland target；条件脚本避免它在 GNOME 恢复会话启动。
  niriSessionCondition = pkgs.writeShellScript "noctalia-niri-session" ''
    for session in \
      "''${XDG_CURRENT_DESKTOP:-}" \
      "''${XDG_SESSION_DESKTOP:-}" \
      "''${DESKTOP_SESSION:-}"; do
      if [ "$session" = "niri" ]; then
        exit 0
      fi
    done

    exit 1
  '';
in

{
  # settings、调色板和插件保持官方默认空值。
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  # 复用官方 noctalia 用户服务，仅限制其在 Niri 会话中执行。
  systemd.user.services.noctalia.Service.ExecCondition = [ niriSessionCondition ];
}
