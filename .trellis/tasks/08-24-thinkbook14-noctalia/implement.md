# 阶段 7：Noctalia v5 官方默认桌面外壳实施清单

## 实施前门禁

- [x] 阅读 Noctalia v5 官方文档、官方 Flake 和 Home Manager 模块。
- [x] 确认阶段 6 已归档，Niri 官方会话已接入并保留 GNOME 回退。
- [x] 确认 Noctalia v4、Waybar、自定义 Niri KDL 和自定义 Noctalia 配置均不属于本阶段。

## 有序实施步骤

1. [x] 将 `noctalia.homeModules.default` 接入 Home Manager 用户模块。
2. [x] 创建 `modules/home/noctalia.nix`，只启用 `programs.noctalia.enable` 和 `.systemd.enable`。
3. [x] 为官方 `noctalia` 用户服务添加仅限 Niri 的 ExecCondition，不添加第二份服务。
4. [x] 保持 settings、customPalettes、插件和主题为空，静态排除 v4 与 Waybar。
5. [x] 更新 README、主任务清单、阶段记录和规范。
6. [x] 运行静态边界检查与 `git diff --check`；跳过 `nix fmt` 和 `nixos-rebuild boot`。

## 自动验证

```sh
nix flake check --no-build --show-trace
nix eval --json .#nixosConfigurations.thinkbook14.config.home-manager.users.wenzhengcheng.programs.noctalia.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.home-manager.users.wenzhengcheng.programs.noctalia.systemd.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.systemd.user.services.noctalia
nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel --no-link --show-trace
```

GitHub Actions 负责 Flake 检查、配置枚举和闭包构建；本地没有 Nix。CI 不能替代真实 Niri/GNOME 会话验证。

## 手动验收与归档记录

- [ ] 用户在 Niri 中验证状态栏、启动器、通知、快捷设置和默认外壳（延期）。
- [ ] 用户在 GNOME 中确认 Noctalia 服务未运行，且停用 Noctalia 后 GNOME 仍可用（延期）。
- [x] 按用户最新指令，不等待现场验收；推送成功后直接归档阶段 7并创建阶段 8。

回滚点：停用 Noctalia 用户服务，从 GDM 进入 GNOME，或回退阶段 6系统代。
