# Journal - wenzhengcheng (Part 1)

> AI development session journal
> Started: 2026-08-23

---



## Session 1: 完成阶段 1：仓库与 Nix 规范基础

**Date**: 2026-08-23
**Task**: 完成阶段 1：仓库与 Nix 规范基础
**Branch**: `master`

### Summary

完成最小 Nix Flake、README 和 Nix 项目规范，提交 5983ce2；由于当前环境未安装 Nix，flake.lock 生成及 nix flake 检查留待目标 NixOS 环境执行。阶段任务已按用户确认归档。

### Git Commits

| Hash | Message |
|------|---------|
| `5983ce2` | (see git log) |

### Status

[OK] **Completed**


## Session 2: 完成 thinkbook14 通用笔记本角色

**Date**: 2026-08-24
**Task**: 完成 thinkbook14 通用笔记本角色
**Branch**: `master`

### Summary

新增可复用的通用笔记本系统角色，启用 NetworkManager、PipeWire PulseAudio 兼容层、Bluetooth、UPower、Power Profiles Daemon、Polkit 与 fwupd，并显式关闭指纹、打印和 Bolt 授权服务。thinkbook14 入口仅导入该角色；静态检查通过，Nix 验证待目标 NixOS 执行。

### Git Commits

| Hash | Message |
|------|---------|
| `d9f9792` | (see git log) |

### Status

[OK] **Completed**


## Session 3: 阶段 4：Home Manager 与 Fcitx5

**Date**: 2026-08-24
**Task**: 阶段 4：Home Manager 与 Fcitx5
**Branch**: `master`

### Summary

完成 thinkbook14 单用户 Home Manager 接入，启用 Fcitx5 与 fcitx5-rime，更新 Nix 配置规范并完成静态检查；Nix 格式、求值、闭包构建和目标设备手动验收待目标 NixOS 执行。

### Git Commits

| Hash | Message |
|------|---------|
| `b3430e5` | (see git log) |
| `e36004d` | (see git log) |

### Status

[OK] **Completed**


## Session 4: 补录阶段 2：thinkbook14 核心系统与引导

**Date**: 2026-08-23
**Task**: thinkbook14 核心系统与引导
**Branch**: `master`

### Summary

补录阶段 2：建立 `thinkbook14` 核心系统闭包、主机入口和 `nixosConfigurations.thinkbook14`，声明 systemd-boot、EFI 变量写入和最多保留 10 个系统代。阶段范围明确排除真实硬件配置、磁盘事实和现场部署；静态边界检查通过，Nix 格式、求值和闭包构建待目标 NixOS 环境执行。

### Git Commits

| Hash | Message |
|------|---------|
| `7edd4e8` | feat: 建立 thinkbook14 核心系统闭包 |

### Testing

- [OK] 静态范围检查和 `git diff --check` 通过。
- [P] `nix flake check`、主机闭包构建和关键选项求值待目标 NixOS 执行。

### Status

[OK] **Completed**（本条为历史补录）


## Session 5: 阶段 5：GDM 与精简 GNOME 恢复会话

**Date**: 2026-08-24
**Task**: 阶段 5：GDM 与精简 GNOME 恢复会话
**Branch**: `master`

### Summary

接入 GDM 与精简 GNOME 恢复会话，关闭自动登录和 GNOME 核心应用集合，保留 Shell、控制中心、Nautilus 及门户基础能力；同时显式关闭 NixOS 层 IBus，保持 Fcitx5、Bolt、打印和指纹服务的配置所有权边界。静态检查完成，真实设备登录、中文输入、注销和回滚验收按用户指令延期。

### Git Commits

| Hash | Message |
|------|---------|
| `726cf2b` | feat: 接入 GDM 与精简 GNOME 恢复会话 |

### Testing

- [OK] [NixOS Flake Check #2](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32663776376) 通过。
- [OK] [NixOS Build #2](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32663810179) 通过并完成 `thinkbook14` 闭包构建。
- [P] 真实设备 GDM/GNOME/Fcitx5 与回滚验收延期。

### Status

[OK] **Completed**


## Session 6: 阶段 6：Niri 官方默认会话

**Date**: 2026-08-24
**Task**: 阶段 6：Niri 官方默认会话
**Branch**: `master`

### Summary

接入 NixOS 26.05 官方 Niri 模块和最小运行时依赖 Alacritty、Fuzzel、`xwayland-satellite`，保留 GDM/GNOME 回退入口，不创建 Niri KDL、主题、快捷键、布局、插件或 Waybar。自动检查完成，真实 Niri 会话、Fcitx5 输入和回退验收按用户指令延期。

### Git Commits

| Hash | Message |
|------|---------|
| `35dfef6` | feat: 接入阶段6官方Niri会话 |

### Testing

- [OK] [NixOS Flake Check #3](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32664721585) 通过。
- [OK] [NixOS Build #3](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32664754499) 通过，配置枚举和 `thinkbook14` 闭包构建成功。
- [P] 真实设备 Niri/GNOME/Fcitx5 会话验收延期。

### Status

[OK] **Completed**


## Session 7: 阶段 7：Noctalia v5 官方默认桌面外壳

**Date**: 2026-08-24
**Task**: 阶段 7：Noctalia v5 官方默认桌面外壳
**Branch**: `master`

### Summary

接入 Noctalia v5 官方 Home Manager 模块，仅启用 Noctalia 和 systemd 用户服务，并通过 Niri 会话条件限制服务启动。保持默认 settings、调色板和插件为空，不引入 Noctalia v4、Waybar 或自定义 Niri 配置；状态栏、启动器、通知、快捷设置和 GNOME 回退等现场验收延期。

### Git Commits

| Hash | Message |
|------|---------|
| `eadc352` | feat: 接入阶段7官方Noctalia外壳 |

### Testing

- [OK] [NixOS Flake Check #4](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32665117984) 通过。
- [OK] 静态审查确认 Noctalia 服务绑定 Niri 会话，未混入 v4 配置。
- [P] 真实 Niri/Noctalia 桌面和 GNOME 回退验收延期。

### Status

[OK] **Completed**


## Session 8: 阶段 8：文档与多设备扩展验收

**Date**: 2026-08-24
**Task**: 阶段 8：文档与多设备扩展验收
**Branch**: `master`

### Summary

完成架构与运维文档，记录模块所有权、新增设备流程、输入更新、CI、构建、部署、回滚、系统代清理和 Windows EFI 人工门禁；同步整理阶段 1–7 的自动检查与现场验收状态。未伪造第二台设备，不执行 `nix fmt`、`boot`、`switch` 或 EFI 写入。

### Git Commits

| Hash | Message |
|------|---------|
| `a773768` | docs: 完成阶段8架构与运维文档 |
| `f9b317d` | docs: 更新主任务阶段8验收状态 |

### Testing

- [OK] `git diff --check` 和公共模块静态泄漏审查通过。
- [OK] [NixOS Flake Check #5](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32665778470) 通过。
- [P] 归档时 [NixOS Build #5](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32665818260) 尚在构建，未将其记录为成功。

### Status

[OK] **Completed**


## Session 9: 主任务最终 CI 与仓库收尾

**Date**: 2026-08-24
**Task**: 构建可维护的多设备 NixOS 26.05 配置仓库
**Branch**: `master`

### Summary

记录主任务最终 CI 状态并归档父任务，随后清理旧的构建工作流并更新 NixOS 检查工作流。主任务所有阶段均已完成；真实设备会话、输入法、硬件和 EFI 验收仍按各阶段记录保持为延期事项。

### Git Commits

| Hash | Message |
|------|---------|
| `52e2712` | docs: 记录主任务最终CI状态 |
| `1cb1823` | chore(task): archive 08-23-nixos-26-05-multi-device |
| `4944f65` | Delete .github/workflows/nixos-build.yml |
| `5e06228` | update nixos-check action |

### Status

[OK] **Completed**
