# NixOS 配置运维与验收流程

## 输入与锁定

仓库输入位于 `flake.nix`：Nixpkgs 26.05、Home Manager `release-26.05` 和 Noctalia 官方 Flake，后两者跟随仓库 Nixpkgs。当前工作区没有 `flake.lock`；只能在目标 NixOS 环境运行 `nix flake lock` 生成并审阅，不能手工猜测锁定值。

输入更新流程：

1. 阅读变更目标和对应官方版本边界。
2. 在具备 Nix 的环境运行 `nix flake lock` 或按输入单独更新。
3. 审阅 `flake.lock` 的修订、依赖树和 `follows`，确认没有第二份未预期 Nixpkgs。
4. 运行允许的 Flake 检查和主机闭包构建，推送后以 GitHub Actions 结果为自动证据。

## 自动检查与当前策略

GitHub Actions 工作流执行：

```sh
nix flake check --no-build --show-trace
nix eval --json .#nixosConfigurations --apply builtins.attrNames
nix build .#nixosConfigurations.<主机名>.config.system.build.toplevel --no-link --show-trace
```

本地工作区没有 Nix。按本次用户指令跳过 `nix fmt`、`nixos-rebuild boot` 和 `nixos-rebuild switch`；文档与代码变更仍运行：

```sh
git diff --check
```

CI 绿色只证明 Flake 可求值、主机闭包可构建和 Home Manager 能合并，不证明真实显示管理器登录、输入法、Noctalia 外壳或回滚现场操作。

## 构建与部署边界

只构建不改变运行系统：

```sh
nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel --no-link --show-trace
```

目标设备具备硬件事实并获得现场授权后，才可选择：

```sh
sudo nixos-rebuild boot --flake .#thinkbook14
sudo nixos-rebuild switch --flake .#thinkbook14
```

`boot` 只写入下一次启动使用的系统代，适合先验证；`switch` 会立即切换当前系统，必须先确认 GDM、GNOME、Niri、输入法和回滚路径。本文档记录命令用途，不表示本阶段已经执行这些命令。

## 回滚与系统代清理

发现图形登录或桌面外壳问题时，优先从 systemd-boot 选择上一已验证系统代，或从 TTY 使用：

```sh
sudo nixos-rebuild switch --rollback
```

确认稳定运行后查看系统代并只删除明确的旧代：

```sh
sudo nix-env --profile /nix/var/nix/profiles/system --list-generations
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations OLD_GENERATION
sudo nix-collect-garbage --delete-older-than 30d
```

不要在未确认当前代和回滚代之前批量删除系统代；垃圾回收不能替代系统代回滚验证。

## Windows 与 EFI 人工门禁

| 情况 | 处理边界 |
| --- | --- |
| NixOS 与 Windows 使用同一个 EFI 系统分区 | 先确认真实挂载点和现有 loader 文件，再按官方 systemd-boot 流程部署；不猜路径 |
| 两者使用不同 EFI 分区或不同磁盘 | 先收集真实分区、挂载和固件启动项信息，再决定链式启动；不得自动复制 UUID |
| 无法确认 UEFI/EFI 分区/Windows loader | 停止 `boot`/`switch` 和 EFI 写入，只允许求值、构建和文档工作 |
| 现场启动项缺失 | 保留上一系统代和原 Windows EFI 文件，使用目标设备的真实固件信息修复 |

公共 Flake 和角色不得写入 EFI 分区、Windows loader 名称、磁盘 UUID 或绝对设备路径。硬件文件必须来自目标设备的 NixOS 生成结果。

## 阶段验收记录

| 阶段 | 自动证据 | 现场验收状态 | 归档状态 |
| --- | --- | --- | --- |
| 1–4 | 对应归档子任务中的静态/CI记录 | 按阶段记录保留 | 已归档 |
| 5 GDM/GNOME | [Flake Check #2](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32663776376)、[Build #2](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32663810179) | GDM、GNOME、Fcitx5、注销和回滚延期 | 已归档 |
| 6 Niri | [Flake Check #3](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32664721585)、[Build #3](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32664754499) | Niri、快捷键、Fuzzel、输入法和 GNOME 回退延期 | 已归档 |
| 7 Noctalia | [Flake Check #4](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32665117984)、[Build #4](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32665152753) | 外壳行为和 GNOME 隔离延期；构建结果以链接当前状态为准 | 已归档 |
| 8 文档 | 推送本阶段后触发新的 Flake Check/Build | 不涉及现场系统 | 本阶段完成后归档 |

阶段归档表示用户授权的计划流程已完成，不把延期的现场验收改写成通过。
