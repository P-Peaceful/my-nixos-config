# 官方模块研究摘要

## 研究范围

本文件只记录设计所依赖的官方接口与兼容性事实。实际实现必须以 `flake.lock` 锁定版本中的选项定义为最终依据。

## NixOS 26.05

### systemd-boot

- NixOS 26.05 官方手册推荐 UEFI 系统使用 `boot.loader.systemd-boot.enable`。
- systemd-boot 需要 UEFI；NixOS 默认期望 EFI 系统分区挂载在 `/boot`，实际挂载点必须与机器生成的硬件配置一致。
- Windows 与 NixOS 位于同一 EFI 系统分区时通常无需额外发现配置；位于不同 EFI 系统分区或不同磁盘时，需要使用官方双系统文档中的链式启动方案。
- `boot.loader.systemd-boot.configurationLimit` 用于限制引导菜单中的系统代数量。

来源：

- <https://nixos.org/manual/nixos/stable/>
- <https://wiki.nixos.org/wiki/Systemd/boot>
- <https://wiki.nixos.org/wiki/Dual_Booting_NixOS_and_Windows>

### Niri

- NixOS 26.05 提供 `programs.niri.enable`。
- 官方模块负责安装 Niri、注册显示管理器会话、启用推荐的 GNOME/GTK 门户和 GNOME Keyring。
- `programs.niri.useNautilus` 默认为真，用 Nautilus 支撑 GNOME 文件选择门户。
- Niri 在用户和系统配置均不存在时，会把二进制内嵌的默认配置写入用户配置目录。
- 默认配置引用 Alacritty、Fuzzel 和 Waybar；本仓库安装 Alacritty 与 Fuzzel，不安装 Waybar，由 Noctalia 提供桌面外壳。
- Niri 原生支持 `xwayland-satellite`，上游建议把它放入 `PATH` 以兼容 X11 应用。

来源：

- <https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/programs/wayland/niri.nix>
- <https://github.com/niri-wm/niri/wiki/Integrating-niri>
- <https://github.com/niri-wm/niri/wiki/Getting-Started>

### GNOME 与 GDM

- `services.displayManager.gdm.enable` 启用 GDM。
- `services.desktopManager.gnome.enable` 注册 GNOME 会话。
- `services.gnome.core-apps.enable` 可显式关闭 GNOME 核心应用集合，同时保留 Shell 与基础服务。
- GNOME 模块会为 NetworkManager、Bluetooth、Polkit、UPower、Power Profiles Daemon、Bolt、IBus 等设置默认值；实现必须显式覆盖本任务排除的 Bolt 与 IBus，避免范围漂移。

来源：

- <https://nixos.org/manual/nixos/stable/>
- <https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/services/desktop-managers/gnome.nix>

### Fcitx5

- NixOS 26.05 的新接口是 `i18n.inputMethod.enable = true` 配合 `i18n.inputMethod.type = "fcitx5"`；旧的 `enabled` 选项已弃用。
- Home Manager 提供同名的用户级 Fcitx5 模块、附加组件列表、会话变量和 systemd 用户服务。
- 本仓库由 Home Manager 作为唯一 Fcitx5 所有者，并显式关闭 GNOME 在 NixOS 层默认启用的 IBus，避免两个输入法守护进程竞争。
- 只启用 `fcitx5-rime`，不声明自定义词库、主题或快捷键。

来源：

- <https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/i18n/input-method/default.nix>
- <https://github.com/nix-community/home-manager/blob/release-26.05/modules/i18n/input-method/fcitx5.nix>

## Home Manager 26.05

- Home Manager 使用 `release-26.05`，作为 NixOS 模块随系统一起构建。
- `home-manager.useGlobalPkgs = true` 让 Home Manager 使用系统的同一个 `pkgs`。
- `home-manager.useUserPackages = true` 让用户包进入系统管理的每用户配置路径。
- `home.stateVersion` 固定为 `26.05`，以后更新 Home Manager 时不自动修改。

来源：

- <https://nix-community.github.io/home-manager/nix-flakes.html>
- <https://nix-community.github.io/home-manager/installation/nixos.html>

## Noctalia v5

- 官方 Flake 提供 `homeModules.default` 与 `nixosModules.default`。
- Home Manager 模块提供 `programs.noctalia.enable`、`programs.noctalia.systemd.enable` 和构建时配置验证。
- 当 `settings = { }` 时不生成自定义配置文件，Noctalia 使用官方默认配置。
- systemd 用户服务绑定到 Wayland 会话 target，可在不修改 Niri 默认 KDL 配置的情况下启动 Noctalia。
- Home Manager 的 Wayland target 默认是通用 `graphical-session.target`；为避免 Noctalia 在 GNOME 恢复会话中启动，需要添加基于 Niri 会话环境的最小 systemd 启动条件，并在真实会话中验证环境值。
- v4 `noctalia-shell` 与 v5 模块、包和配置路径不兼容，不得混用。

来源：

- <https://docs.noctalia.dev/noctalia/getting-started/nixos/>
- <https://github.com/noctalia-dev/noctalia/blob/main/flake.nix>
- <https://github.com/noctalia-dev/noctalia/blob/main/nix/home-module.nix>

## 实现期强制复核

- 在锁定 NixOS 26.05 后，以 `nix eval` 或选项文档确认所有选项仍存在且类型一致。
- 在部署 systemd-boot 前，确认 UEFI 模式、EFI 系统分区挂载点以及 Windows EFI 文件位置。
- 若 Windows 未自动显示，不得猜测 UUID 或设备路径；先收集真实分区与 EFI 信息，再采用官方链式启动方案。
- GNOME 启用后必须检查最终合并配置，确认 IBus、Bolt、打印和自动登录没有被间接启用；Bolt/打印的唯一配置所有者仍是通用笔记本角色。
- 分别登录 Niri 与 GNOME，确认 Noctalia 服务只在 Niri 中启动；若会话环境值与预期不同，暂停并依据实际 systemd 用户环境修正条件。
