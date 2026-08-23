# NixOS 配置仓库

当前仓库处于阶段 2：`thinkbook14` 核心系统与 systemd-boot 配置。当前提供不含图形桌面、硬件事实和现场部署的通用 NixOS 系统闭包入口。

## 当前阶段边界

- `flake.nix` 声明 Nixpkgs 26.05、Home Manager `release-26.05`、Noctalia 官方 Flake、`x86_64-linux` 格式化器以及 `nixosConfigurations.thinkbook14`。
- Home Manager 和 Noctalia 的 Nixpkgs 输入跟随仓库的 `nixpkgs` 输入。
- `modules/nixos/core/` 保存核心系统设置，`hosts/thinkbook14/` 保存主机身份和 systemd-boot 声明。
- 当前不包含 `hardware-configuration.nix`、图形桌面、Home Manager、输入法或阶段 3 的笔记本服务。

## 输入与锁定

输入源和版本策略记录在 [`flake.nix`](./flake.nix) 与项目规范中。本阶段按任务范围不生成 `flake.lock`，因此输入未锁定带来的可复现性风险由后续流程单独处理。

## 检查命令

```sh
nix flake metadata
nix flake check
nix fmt -- --check .
nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel
nix eval --raw .#nixosConfigurations.thinkbook14.config.networking.hostName
```

本工作区无法执行上述命令，因为没有安装 Nix；以上检查均为“待目标 NixOS 执行”，不能标记为已通过：

- `nix flake metadata`
- `nix flake check`
- `nix fmt -- --check .`
- `nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel`
- `nix eval --raw .#nixosConfigurations.thinkbook14.config.networking.hostName`

## 后续阶段边界

本阶段不执行 `nixos-rebuild boot` 或 `switch`，不写入 EFI，也不验证真实设备的硬件、Windows 启动项和系统代。后续硬件集成工作如需部署，必须另行确认现场信息和回滚方案。
