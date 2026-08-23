# NixOS 配置仓库

当前仓库处于阶段 4：`thinkbook14` 核心系统、systemd-boot 配置、通用笔记本系统服务，以及单用户 Home Manager 和 Fcitx5 + Rime 配置。当前仍不含图形桌面和现场部署。

## 当前阶段边界

- `flake.nix` 声明 Nixpkgs 26.05、Home Manager `release-26.05`、Noctalia 官方 Flake、`x86_64-linux` 格式化器以及 `nixosConfigurations.thinkbook14`。
- Home Manager 和 Noctalia 的 Nixpkgs 输入跟随仓库的 `nixpkgs` 输入。
- `modules/nixos/core/` 保存核心系统设置，`hosts/thinkbook14/` 保存主机身份和 systemd-boot 声明。
- `modules/nixos/roles/laptop.nix` 保存跨设备通用的笔记本系统服务；主机入口只负责导入该角色。
- `home/core/` 保存可跨用户复用的 Home Manager 基础入口，`home/wenzhengcheng/` 保存用户状态版本和最小 Fcitx5 + Rime 配置。
- Home Manager 负责用户级输入法配置；当前不包含图形桌面、自定义词库/主题/布局/快捷键或现场部署。

## 输入与锁定

输入源和版本策略记录在 [`flake.nix`](./flake.nix) 与项目规范中。本阶段按任务范围不生成 `flake.lock`，因此输入未锁定带来的可复现性风险由后续流程单独处理。

## 检查命令

```sh
nix flake metadata
nix flake check
nix fmt -- --check .
nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel
nix eval --raw .#nixosConfigurations.thinkbook14.config.networking.hostName
nix eval --json .#nixosConfigurations.thinkbook14.config.home-manager.useGlobalPkgs
nix eval --json .#nixosConfigurations.thinkbook14.config.home-manager.useUserPackages
nix eval --json .#nixosConfigurations.thinkbook14.config.home-manager.users.wenzhengcheng.home.stateVersion
```

本工作区无法执行上述命令，因为没有安装 Nix；以上检查均为“待目标 NixOS 执行”，不能标记为已通过：

- `nix flake metadata`
- `nix flake check`
- `nix fmt -- --check .`
- `nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel`
- `nix eval --raw .#nixosConfigurations.thinkbook14.config.networking.hostName`
- `nix eval --json .#nixosConfigurations.thinkbook14.config.home-manager.useGlobalPkgs`
- `nix eval --json .#nixosConfigurations.thinkbook14.config.home-manager.useUserPackages`
- `nix eval --json .#nixosConfigurations.thinkbook14.config.home-manager.users.wenzhengcheng.home.stateVersion`

## 后续阶段边界

本阶段不执行 `nixos-rebuild boot` 或 `switch`，不写入 EFI，也不验证真实设备的硬件、Windows 启动项和系统代。后续硬件集成工作如需部署，必须另行确认现场信息和回滚方案。
