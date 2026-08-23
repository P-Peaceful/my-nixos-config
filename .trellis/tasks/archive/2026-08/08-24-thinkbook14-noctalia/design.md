# 阶段 7：Noctalia v5 官方默认桌面外壳技术设计

## 模块边界

```text
flake.nix
  └─ Home Manager 用户入口
       ├─ noctalia.homeModules.default
       ├─ home/wenzhengcheng/default.nix
       └─ modules/home/noctalia.nix
```

- `flake.nix` 只负责把官方 `noctalia.homeModules.default` 接入 Home Manager 用户模块。
- `modules/home/noctalia.nix` 负责 Noctalia 启用合同和 Niri-only systemd 条件。
- `home/wenzhengcheng/default.nix` 继续负责用户组合和 Fcitx5，不复制 Noctalia 的选项。
- NixOS 层只保留阶段 5 GDM/GNOME 和阶段 6 Niri；Noctalia 属于用户级桌面外壳。

## 配置合同

```nix
programs.noctalia = {
  enable = true;
  systemd.enable = true;
};

systemd.user.services.noctalia.Service.ExecCondition =
  "${pkgs.writeShellScript "noctalia-niri-session" ...}";
```

不设置 `programs.noctalia.settings`、`customPalettes` 或插件；官方模块默认 `settings = { }`，因此不生成自定义 TOML。官方服务仍绑定 `config.wayland.systemd.target`，额外 ExecCondition 只允许 Niri 会话环境通过。

会话判定按 `XDG_CURRENT_DESKTOP`、`XDG_SESSION_DESKTOP` 或 `DESKTOP_SESSION` 任一值为 `niri`；使用 ExecCondition 而非多个 systemd `ConditionEnvironment`，避免多个条件被解释为 AND。

## 数据流与验证

```text
noctalia Flake homeModules.default
  → Home Manager programs.noctalia
  → systemd.user.services.noctalia
  → Wayland session target + Niri-only ExecCondition
  → Noctalia official default shell
```

CI 验证模块导入、Noctalia 选项、服务条件和主机闭包；静态检查拒绝 v4、settings、palettes、plugins、Waybar 和 Niri KDL。现场验证负责确认 Niri 中外壳实际可用以及 GNOME 中服务不运行。

## 兼容性与回滚

- Noctalia v5 官方模块的 `programs.noctalia.package` 由 `homeModules.default` 提供，不能手工切换到旧包。
- 如果服务条件或外壳失败，停用用户服务并从 GDM 选择 GNOME；不修改 Niri 默认配置或执行 boot/switch。
