# 阶段 6：Niri 官方默认会话实施清单

## 实施前门禁

- [x] 阅读 Nix 项目规范和父任务 Niri 官方模块研究。
- [x] 确认阶段 5 已归档并保留 GDM/GNOME 恢复入口。
- [x] 确认阶段 6 不引入 Noctalia、Waybar 或自定义 Niri 配置。

## 有序实施步骤

1. [x] 创建 `modules/nixos/desktop/niri.nix`，仅启用官方 Niri 和 Nautilus 集成。
2. [x] 在同一模块加入 Alacritty、Fuzzel、`xwayland-satellite`，不加入 Waybar。
3. [x] 在 `hosts/thinkbook14/default.nix` 导入阶段 6 模块，不修改硬件、用户或 Flake 输入。
4. [x] 静态检查没有 Niri KDL、settings、Noctalia、Waybar、主题、布局、快捷键和插件配置。
5. [x] 更新 README、阶段主任务清单和验收记录，明确 CI 验证范围及现场验收延期。
6. [x] 运行允许的静态检查与 `git diff --check`；跳过 `nix fmt` 和 `nixos-rebuild boot`。

## 自动验证

```sh
nix flake check --no-build --show-trace
nix eval --json .#nixosConfigurations.thinkbook14.config.programs.niri.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.programs.niri.useNautilus
nix eval --json .#nixosConfigurations.thinkbook14.config.services.displayManager.gdm.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.services.desktopManager.gnome.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.environment.systemPackages
nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel --no-link --show-trace
```

GitHub Actions 负责 Flake 检查、配置枚举和主机闭包构建；本地没有 Nix，未执行本地 Nix 命令。提交 `35dfef6` 的自动验证结果：

- [x] `NixOS Flake Check #3`：<https://github.com/P-Peaceful/my-nixos-config/actions/runs/32664721585>
- [x] `NixOS Build #3`：<https://github.com/P-Peaceful/my-nixos-config/actions/runs/32664754499>，配置枚举与 `thinkbook14` 闭包构建成功。

不得把 CI 绿色结果解释为真实会话验收。

## 手动验收与归档记录

- [ ] 用户从 GDM 选择 Niri 并成功进入上游默认会话（延期）。
- [ ] 用户验证官方默认快捷键、Alacritty、Fuzzel、xwayland-satellite 和 Fcitx5 + Rime（延期）。
- [ ] 用户从 Niri 注销回 GDM，并进入 GNOME 恢复会话（延期）。
- [x] 按用户最新指令，不等待上述现场验收；推送成功后直接归档阶段 6并创建阶段 7。

回滚点：从 GDM 选择 GNOME，或回退阶段 5系统代；不执行 `nixos-rebuild boot` 或 `switch`。
