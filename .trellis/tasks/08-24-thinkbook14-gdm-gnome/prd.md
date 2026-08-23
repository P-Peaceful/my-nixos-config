# 阶段 5：GDM 与精简 GNOME 恢复会话

## 目标与用户价值

在阶段 4 的 Home Manager 与 Fcitx5 基础上，先提供不依赖 Niri 或 Noctalia 的 GNOME 恢复会话。用户可以从 GDM 使用密码登录 GNOME，并在桌面外壳后续阶段失败时保留可用的图形恢复入口。

## 背景与约束

- 阶段 1–4 已完成；`thinkbook14` 已组合核心系统、通用笔记本角色和 Home Manager 用户入口。
- 本阶段只新增 GDM 和 GNOME 恢复能力，不启用 Niri、Noctalia 或任何个性化桌面配置。
- GDM 必须是唯一显示管理器，自动登录必须关闭。
- GNOME 核心应用集合关闭，但必须保留 GNOME Shell、控制中心、Nautilus 和恢复所需门户/基础服务。
- Home Manager 是 Fcitx5 + Rime 的唯一用户级输入法所有者；GNOME 在 NixOS 层默认启用的 IBus 必须显式关闭。
- 指纹、打印和 Bolt/Thunderbolt 授权不属于本任务；GNOME 模块产生的默认值必须显式复核并关闭。
- 当前工作区没有 Nix；未运行的 Nix 检查只能记录为“待目标 NixOS 执行”。不得执行 `nixos-rebuild boot` 或 `switch`。

## 范围内需求

- R1：启用 `services.displayManager.gdm.enable`，并显式关闭 `services.displayManager.autoLogin.enable`。
- R2：启用 `services.desktopManager.gnome.enable`，关闭 `services.gnome.core-apps.enable`，保留 Shell、控制中心、Nautilus 和门户基础能力。
- R3：显式关闭最终合并配置中的 NixOS 层 `i18n.inputMethod.enable`、`services.hardware.bolt.enable` 和 `services.printing.enable`，其中 Bolt/打印沿用通用笔记本角色的唯一关闭合同，避免与 Home Manager Fcitx5 及阶段边界冲突。
- R4：将阶段 5 模块接入 `thinkbook14`，不修改硬件事实、不新增第二个用户、不引入 Niri/Noctalia。
- R5：记录自动检查、现场手动验收、官方依据、已知风险和从阶段 4 系统代回滚点。

## 验收标准

- [ ] AC1：GDM 与 GNOME 选项求值为启用，自动登录求值为关闭，未声明其他显示管理器。
- [ ] AC2：GNOME 核心应用集合求值为关闭，但最终系统包包含 `gnome-shell`、`gnome-control-center` 和 `nautilus`，GNOME 门户可用。
- [ ] AC3：最终合并配置中 IBus、Bolt、打印和指纹服务关闭；Home Manager Fcitx5 配置未被 NixOS 层重复声明。
- [ ] AC4：静态审查证明阶段 5 未引入 Niri、Noctalia、Waybar、布局、快捷键、主题、插件或现场部署动作。
- [ ] AC5：在具备 Nix 的目标环境运行格式检查、`nix flake check`、主机闭包构建和关键选项求值；当前环境统一记录为“待目标 NixOS 执行”。
- [ ] AC6：用户在真实设备验证 GDM 密码登录、GNOME 会话、Fcitx5 + Rime、注销返回 GDM；验证完成前不得开始阶段 6。

## 范围外、风险与回滚

- 范围外：Niri、Noctalia、桌面主题、个人应用、自定义 GNOME 设置、系统切换、EFI 写入和第二台设备。
- GNOME 模块可能随 NixOS 输入改变默认服务；必须以锁定输入实际求值结果为准。
- 如果图形登录或 Fcitx5 出现问题，从阶段 4 已验证系统代启动，或使用 TTY 禁用本阶段模块；本任务不修改引导数据。
