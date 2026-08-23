# NixOS 配置仓库

当前仓库处于阶段 7：`thinkbook14` 核心系统、systemd-boot 配置、通用笔记本系统服务、单用户 Home Manager 和 Fcitx5 + Rime 配置、GDM/GNOME 恢复会话、NixOS 官方 Niri 会话，以及 Noctalia v5 官方默认桌面外壳。当前仍未执行现场部署。

## 当前阶段边界

- `flake.nix` 声明 Nixpkgs 26.05、Home Manager `release-26.05`、Noctalia 官方 Flake、`x86_64-linux` 格式化器以及 `nixosConfigurations.thinkbook14`。
- Home Manager 和 Noctalia 的 Nixpkgs 输入跟随仓库的 `nixpkgs` 输入。
- `modules/nixos/core/` 保存核心系统设置，`hosts/thinkbook14/` 保存主机身份和 systemd-boot 声明。
- `modules/nixos/roles/laptop.nix` 保存跨设备通用的笔记本系统服务；主机入口只负责导入该角色。
- `modules/nixos/desktop/gdm-gnome.nix` 保存 GDM、精简 GNOME 恢复会话和 IBus 阶段边界覆盖；Bolt、打印和指纹关闭由通用笔记本角色统一持有。
- `modules/nixos/desktop/niri.nix` 保存 NixOS 官方 Niri 会话和 Alacritty、Fuzzel、`xwayland-satellite` 最小运行时依赖；不创建 Niri KDL、不安装 Waybar。
- `modules/home/noctalia.nix` 保存 Noctalia v5 用户服务启用和仅限 Niri 会话的启动条件；不生成自定义 settings、调色板或插件配置。
- `home/core/` 保存可跨用户复用的 Home Manager 基础入口，`home/wenzhengcheng/` 保存用户状态版本和最小 Fcitx5 + Rime 配置。
- Home Manager 负责用户级输入法和 Noctalia 用户服务；GNOME 核心应用集合关闭但保留 Shell、控制中心、Nautilus 和门户基础服务；Niri 使用官方默认配置，Noctalia 仅在 Niri 会话条件满足时运行，当前不包含自定义词库/主题/布局/快捷键或现场部署。

## 输入与锁定

输入源和版本策略记录在 [`flake.nix`](./flake.nix) 与项目规范中。当前工作区尚未包含 `flake.lock`；本环境没有 Nix，不能手工猜测或生成锁定值。交付前必须在目标 NixOS 环境运行 `nix flake lock`，审阅锁文件后再执行完整 Flake 检查。

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
nix eval --json .#nixosConfigurations.thinkbook14.config.services.displayManager.gdm.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.services.displayManager.autoLogin.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.services.desktopManager.gnome.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.services.gnome.core-apps.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.i18n.inputMethod.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.services.hardware.bolt.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.services.printing.enable
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
- `nix eval --json .#nixosConfigurations.thinkbook14.config.services.displayManager.gdm.enable`
- `nix eval --json .#nixosConfigurations.thinkbook14.config.services.displayManager.autoLogin.enable`
- `nix eval --json .#nixosConfigurations.thinkbook14.config.services.desktopManager.gnome.enable`
- `nix eval --json .#nixosConfigurations.thinkbook14.config.services.gnome.core-apps.enable`
- `nix eval --json .#nixosConfigurations.thinkbook14.config.i18n.inputMethod.enable`
- `nix eval --json .#nixosConfigurations.thinkbook14.config.services.hardware.bolt.enable`
- `nix eval --json .#nixosConfigurations.thinkbook14.config.services.printing.enable`

## 后续阶段边界

本阶段不执行 `nixos-rebuild boot` 或 `switch`，不写入 EFI，也不验证真实设备的硬件、Windows 启动项和系统代。按用户最新自动推进指令，阶段 5 的现场验收延期记录，推送后直接归档并进入后续阶段；后续硬件集成工作如需部署，必须另行确认现场信息和回滚方案。
