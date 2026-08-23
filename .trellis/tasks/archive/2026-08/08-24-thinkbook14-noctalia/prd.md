在 Niri 会话上接入 Noctalia v5 官方默认桌面外壳，保持 GNOME 恢复会话独立。

## 约束

- 使用 Flake 中已声明并跟随仓库 Nixpkgs 的 `noctalia` 输入和官方 `homeModules.default`。
- Home Manager 只启用 `programs.noctalia.enable` 与 `programs.noctalia.systemd.enable`；`settings`、`customPalettes` 和插件保持默认空值。
- Noctalia 用户服务必须通过最小会话条件只在 Niri 启动，在 GNOME 中被跳过；不得修改 Niri KDL。
- 不使用 Noctalia v4 的 `noctalia-shell` 包、模块或配置路径。
- 按用户指令跳过 `nix fmt`、`nixos-rebuild boot` 和现场会话验收；推送完成后直接归档进入阶段 8，延期事实保留。

## 范围内需求

- R1：把官方 Noctalia Home Manager 模块接入当前用户配置。
- R2：启用官方 Noctalia 与 systemd 用户服务，使用官方默认配置。
- R3：为 `noctalia` 服务加入 Niri 会话环境条件，避免 GNOME 恢复会话启动 Noctalia。
- R4：不加入自定义设置、调色板、插件、Noctalia v4 或第二份用户服务。
- R5：更新主任务和文档，记录 CI 自动检查与现场验收延期。

## 验收标准

- [ ] AC1：官方 `homeModules.default` 成功导入，Noctalia 包来自锁定 Flake 输入。
- [ ] AC2：`programs.noctalia.enable`、`programs.noctalia.systemd.enable` 为启用，settings/palettes/plugins 保持未配置。
- [ ] AC3：Noctalia 服务只在 Niri 会话条件满足时执行，在 GNOME 中被 ExecCondition 跳过。
- [ ] AC4：静态检查无 v4 `noctalia-shell`、自定义配置、Waybar 或 Niri KDL。
- [ ] AC5：GitHub Actions 通过 Flake 检查、配置枚举和 `thinkbook14` 系统闭包构建；不执行 `nix fmt` 或 `nixos-rebuild boot`。
- [ ] AC6：现场状态栏、启动器、通知、快捷设置、Noctalia 停用后 GNOME 回退验收延期，不阻塞归档。
接入锁定 Noctalia v5 Home Manager 模块，仅在 Niri 会话启用官方默认桌面外壳，保持 GNOME 恢复会话独立。

## Requirements

- TBD

## Acceptance Criteria

- [ ] TBD

## Notes

- Keep `prd.md` focused on requirements, constraints, and acceptance criteria.
- Lightweight tasks can remain PRD-only.
- For complex tasks, add `design.md` for technical design and `implement.md` for execution planning before `task.py start`.
