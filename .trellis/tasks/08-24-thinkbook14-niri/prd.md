# 阶段 6：Niri 官方默认会话

## 目标

在阶段 5 的 GDM/GNOME 恢复入口之后接入 NixOS 26.05 官方 Niri 会话，保留 GNOME 作为独立回退入口，并为 Niri 上游默认配置提供最小运行时依赖。

## 约束

- 只使用 NixOS 26.05 官方 `programs.niri` 模块，不引入第三方 Niri 模块或自定义会话脚本。
- 不创建 `config.kdl`、Niri settings、快捷键、布局、主题或插件配置。
- 安装 Alacritty、Fuzzel 与 `xwayland-satellite`，不安装 Waybar；Noctalia 留到阶段 7。
- GDM 继续作为唯一显示管理器；不设置 `services.displayManager.defaultSession`，由用户在 GDM 选择 Niri 或 GNOME。
- 保持阶段 5 的 GNOME、Home Manager Fcitx5 + Rime、Bolt/打印/指纹关闭合同，不复制配置所有权。
- 本阶段只构建和检查配置，不执行 `nixos-rebuild boot`、`switch` 或 EFI 写入；按用户自动推进指令，推送完成后直接归档并进入阶段 7，现场会话验收延期记录。

## 范围内需求

- R1：启用 `programs.niri.enable`，让官方模块注册 Niri 会话并提供门户、Keyring 等官方集成。
- R2：显式保留官方 `programs.niri.useNautilus` 能力，并确保阶段 5 的 Nautilus 可用于文件门户。
- R3：将 `alacritty`、`fuzzel` 和 `xwayland-satellite` 放入系统闭包；不引入 Waybar。
- R4：阶段 6 模块接入 `thinkbook14`，不修改硬件配置、用户身份、Flake 输入或 Noctalia 配置。
- R5：自动验证 Niri 选项、会话注册、依赖包、门户/Keyring 合并结果和主机闭包；保留现场 Niri/GNOME/Fcitx5 验收延期记录。

## 验收标准

- [ ] AC1：`programs.niri.enable` 和 `programs.niri.useNautilus` 最终求值符合阶段合同。
- [ ] AC2：系统闭包包含 Niri、Alacritty、Fuzzel、`xwayland-satellite` 和 Nautilus；不包含 Waybar、Noctalia v4 或自定义 Niri 配置。
- [ ] AC3：GDM 仍启用且未伪造默认会话；GNOME 恢复入口和阶段 5 服务合同保持存在。
- [ ] AC4：静态审查证明没有 `config.kdl`、Niri settings、主题、布局、快捷键、插件或 `programs.noctalia` 配置进入本阶段。
- [ ] AC5：GitHub Actions 通过 Flake 检查、NixOS 配置枚举和 `thinkbook14` 系统闭包构建；不执行 `nix fmt` 或 `nixos-rebuild boot`。
- [ ] AC6：真实设备的 Niri 启动、官方快捷键、终端、Fuzzel、Fcitx5 + Rime、注销回 GDM 和 GNOME 回退验收延期记录，不阻塞本轮归档。
