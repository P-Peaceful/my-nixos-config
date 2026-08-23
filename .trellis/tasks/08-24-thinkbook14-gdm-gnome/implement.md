# 阶段 5：GDM 与精简 GNOME 实施清单

## 实施前门禁

- [x] 阅读 `.trellis/spec/nix/` 与父任务官方模块研究。
- [x] 确认阶段 4 子任务已归档，Home Manager 是现有 Fcitx5 的唯一配置所有者。
- [x] 以 NixOS 26.05 官方模块确认 GDM、GNOME、core-apps 和 IBus 选项名称。
- [x] 搜索仓库中现有显示管理器、GNOME、输入法、打印和 Bolt 配置，确认接线位置。

## 有序实施步骤

1. [x] 创建 `modules/nixos/desktop/gdm-gnome.nix`，启用 GDM/GNOME，关闭自动登录和 GNOME 核心应用集合。
2. [x] 在该模块保留 GNOME Shell、控制中心、Nautilus 和门户所需的最小恢复能力，禁止 Niri/Noctalia 配置进入本阶段。
3. [x] 显式覆盖 NixOS 层 IBus；复核通用笔记本角色持有的 Bolt、打印和指纹关闭合同在 GNOME 合并后仍保持关闭。
4. [x] 在 `hosts/thinkbook14/default.nix` 导入桌面模块，不修改 Flake 输入、硬件配置或 Home Manager 入口。
5. [x] 更新 README 和阶段主任务清单，记录阶段 5 自动检查结果及现场验收门禁。
6. [x] 运行静态边界检查与 `git diff --check`；本地环境没有 Nix，Nix 验证由 GitHub Actions 执行。

## 自动验证

```sh
nix fmt -- --check .
nix flake check
nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel
nix eval --json .#nixosConfigurations.thinkbook14.config.services.displayManager.gdm.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.services.displayManager.autoLogin.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.services.desktopManager.gnome.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.services.gnome.core-apps.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.i18n.inputMethod.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.services.hardware.bolt.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.services.printing.enable
```

本地环境没有 Nix，未执行本地格式与求值命令；静态边界审查和 `git diff --check` 已通过。提交 `726cf2b` 的 GitHub Actions 结果如下：

- [x] `NixOS Flake Check #2` 成功：<https://github.com/P-Peaceful/my-nixos-config/actions/runs/32663776376>。
- [x] `NixOS Build #2` 成功，完成 `thinkbook14` 系统闭包构建：<https://github.com/P-Peaceful/my-nixos-config/actions/runs/32663810179>。
- [x] 构建工作流的配置枚举步骤成功发现 `thinkbook14`；GDM、GNOME、输入法、Bolt 和打印选项随主机闭包一并进入构建求值。

## 手动验收与归档门禁

- [ ] 用户在真实设备通过 GDM 密码登录 GNOME。
- [ ] 用户在 GNOME 中验证 Fcitx5 + Rime 中文输入、英文输入、控制中心和 Nautilus。
- [ ] 用户注销并返回 GDM；确认未启用自动登录。
- [ ] 用户确认阶段 4 回滚系统代可用。
- [ ] 自动检查与手动验收记录完成后，才将阶段 5 标记完成并归档，再创建阶段 6；当前仅自动检查已完成。
