# 分阶段实施计划

## 执行规则

- 本文件是总任务的阶段地图，总任务本身不直接启动实现。
- 最终规划获批后，只创建并启动阶段 1 子任务；后续子任务在前一阶段自动检查、用户手动验收和提交完成后才创建或启动。
- 每个子任务必须有自己的 PRD、实施清单、上下文清单和验收记录；依赖关系必须写入子任务，不依赖目录顺序暗示。
- 任何阶段不得顺带实现后续阶段内容。

## 阶段 1：仓库与 Nix 规范基础

目标：建立 Nix 项目规范和最小 Flake 骨架，不产生可部署桌面配置。

- [x] 使用 Trellis 规范引导流程，把现有通用前后端占位规范替换或扩展为真实的 Nix/NixOS 目录、模块、格式和验证规范。
- [x] 创建最小 `flake.nix`，只声明 Nixpkgs 26.05、Home Manager 26.05、Noctalia v5 输入及 formatter。
- [x] 生成并提交 `flake.lock`。
- [x] 创建 README，仅说明阶段状态、输入策略和下一阶段前置条件。
- [x] 验证 `nix flake metadata`、`nix flake check` 与格式检查。
- [x] 用户确认锁定输入和仓库骨架后结束阶段。

回滚点：删除阶段 1 新增的 Nix 文件并回到 Trellis-only 仓库；不影响任何已安装系统。

## 阶段 2：thinkbook14 核心系统与引导

依赖：阶段 1 已通过；本阶段按子任务批准的通用闭包范围，不要求 `flake.lock` 或 `hardware-configuration.nix`。

目标：产生不含图形桌面的可构建主机闭包，并验证 systemd-boot、Windows 与系统代回滚。

- [x] 创建 core 模块、`thinkbook14` 主机入口和 `nixosConfigurations.thinkbook14`。
- [x] 声明主机名、state version、Nix 设置、区域、键盘、用户和 sudo 策略。
- [x] 启用 systemd-boot，设置 EFI 变量写入与系统代上限 10。
- [x] 保留 EFI 配置契约，但不在本阶段读取或猜测 UEFI、EFI 分区和 Windows EFI 文件。
- [x] 完成系统闭包配置，不自动切换。
- [x] 完成静态范围检查和 `git diff --check`；Nix 构建与求值待目标环境执行。
- [x] 真实设备系统代、Windows 菜单和链式启动验证明确延后到硬件集成工作。

自动检查：

```bash
nix flake check
nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel
nix eval --raw .#nixosConfigurations.thinkbook14.config.networking.hostName
```

回滚点：systemd-boot 中上一已验证系统代；保留原 Windows EFI 文件。

阶段记录：阶段 2 子任务已完成并归档；由于本阶段采用通用闭包范围，真实硬件和 EFI 现场验收不作为进入阶段 3 的前置条件。

## 阶段 3：通用笔记本角色

依赖：阶段 2 的系统闭包与引导验收通过。

目标：引入与桌面无关的笔记本系统服务。

- [x] 创建可复用 laptop 角色模块。
- [x] 启用 NetworkManager、PipeWire/PulseAudio、Bluetooth、UPower、Power Profiles Daemon、Polkit 和 fwupd。
- [x] 明确保持指纹、打印和 Bolt/Thunderbolt 授权关闭。
- [ ] 通过求值检查最终服务开关，避免 GNOME 尚未加入时隐藏依赖。
- [ ] 用户验证网络、音频、蓝牙、电池状态、性能模式和固件服务。

阶段记录：阶段 3 子任务已完成并归档；角色实现与静态边界检查已完成。由于当前环境没有 Nix，服务选项求值、Flake 检查和系统闭包构建待目标 NixOS 执行；网络、音频、蓝牙、电池、性能模式和 fwupd 的现场验证仍待用户完成。

回滚点：启动阶段 2 系统代。

## 阶段 4：Home Manager 与 Fcitx5

依赖：阶段 3 通过。

目标：接入单用户 Home Manager，并建立中文输入法用户服务；尚不加入显示管理器。

- [x] 接入 Home Manager NixOS 模块，启用 `useGlobalPkgs` 与 `useUserPackages`。
- [x] 创建 `home/wenzhengcheng/default.nix` 与公共 home core。
- [x] 固定 `home.stateVersion = "26.05"`。
- [x] 用 Home Manager 启用 Fcitx5、systemd 用户服务和 `fcitx5-rime`。
- [x] 不声明自定义词库、主题、布局或快捷键。
- [ ] 验证 Home Manager activation package 随系统闭包构建。

回滚点：启动阶段 3 系统代；Home Manager 与系统代一起回退。

阶段记录：阶段 4 子任务已完成并归档；Home Manager 接线、单用户入口和最小 Fcitx5 + Rime 配置已提交，静态检查通过。由于当前环境没有 Nix，格式检查、Flake 求值、系统闭包构建和目标设备上的 activation、中文输入法及用户服务验证仍待目标 NixOS 执行；本阶段未执行 `nixos-rebuild boot` 或 `switch`。

## 阶段 5：GDM 与精简 GNOME 恢复会话

依赖：阶段 4 通过。

目标：先建立独立、可靠的图形恢复入口，再引入 Niri。

- [x] 启用 GDM 并确认自动登录关闭。
- [x] 启用 GNOME 会话，关闭 GNOME core apps。
- [x] 保留 Shell、控制中心、Nautilus 和恢复所需门户。
- [x] 显式关闭 NixOS 层 IBus、Bolt、打印及其他越界默认服务。
- [x] 按用户最新指令延期真实设备手动验收，推送后直接归档阶段 5；未执行的现场项目保留在阶段 5 子任务记录中。

回滚点：启动阶段 4 系统代或使用 TTY。

阶段记录：阶段 5 模块已接入 `thinkbook14`，静态边界检查和 `git diff --check` 已完成。提交 `726cf2b` 已通过 [NixOS Flake Check #2](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32663776376) 与 [NixOS Build #2](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32663810179)，并完成 `thinkbook14` 主机闭包构建；按用户最新指令不执行 `nix fmt`、`nixos-rebuild boot` 及真实设备手动验收，推送后直接归档阶段 5并进入阶段 6。GDM 密码登录、GNOME 基础组件、Fcitx5 + Rime、注销回 GDM 及阶段 4 回滚点仍标记为待现场验证。

## 阶段 6：Niri 官方默认会话

依赖：阶段 5 的 GNOME 恢复入口已通过。

目标：从 GDM 启动使用上游默认配置的 Niri，不加入 Noctalia。

- [x] 启用 NixOS 26.05 官方 Niri 模块。
- [x] 安装 Alacritty、Fuzzel 与 `xwayland-satellite`。
- [x] 不创建 Niri KDL 配置，不安装 Waybar。
- [x] 检查门户、Keyring 和 GDM 会话注册的最终合并结果（自动检查待 CI）。
- [x] 按用户最新指令延期 Niri/GNOME/Fcitx5 现场会话验收，推送后直接归档阶段 6。

回滚点：从 GDM 选择 GNOME，或启动阶段 5 系统代。

阶段记录：阶段 6 已接入官方 Niri 模块和最小运行时依赖，未创建自定义 KDL、Waybar 或 Noctalia 配置。提交 `35dfef6` 已通过 [NixOS Flake Check #3](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32664721585) 和 [NixOS Build #3](https://github.com/P-Peaceful/my-nixos-config/actions/runs/32664754499)，配置枚举与 `thinkbook14` 闭包构建成功；按用户指令延期现场会话验收，阶段 6 可直接归档并进入阶段 7。

## 阶段 7：Noctalia v5 官方默认桌面外壳

依赖：阶段 6 的 Niri 会话已通过。

目标：在 Niri 中启用官方默认 Noctalia v5。

- [x] 导入锁定的 Noctalia v5 Home Manager 模块。
- [x] 只启用 `programs.noctalia.enable` 和 `programs.noctalia.systemd.enable`。
- [x] 保持 `settings`、调色板和插件为空，不生成自定义配置。
- [x] 为官方 Noctalia 用户服务添加仅限 Niri 会话的最小启动条件。
- [x] 静态检查 Noctalia 服务绑定 Wayland 会话 target、Niri-only 条件存在，且代码中不混入 v4。
- [x] 按用户最新指令延期状态栏、启动器、通知、快捷设置及默认桌面外壳现场验收，推送后直接归档阶段 7。
- [x] 按用户最新指令延期停用 Noctalia 后的 GNOME 现场回退验收，保留记录。

回滚点：禁用 Noctalia 服务、从 GDM 进入 GNOME，或启动阶段 6 系统代。

阶段记录：阶段 7 已接入官方 Noctalia v5 Home Manager 模块，仅在 Niri 会话条件满足时运行官方用户服务；settings、调色板、插件、Waybar 和 v4 配置均未加入，待 CI 验证后归档。

## 阶段 8：文档与多设备扩展验收

依赖：阶段 7 通过。

目标：完成长期维护文档和结构验收，不伪造第二台设备。

- [x] 编写架构、模块所有权和新增设备流程，见 [`docs/architecture.md`](../../../docs/architecture.md)。
- [x] 编写输入更新、静态检查、构建、`boot`、`switch`、回滚和系统代清理流程，见 [`docs/operations.md`](../../../docs/operations.md)。
- [x] 记录 Windows 同/异 EFI 分区的处理边界和人工门禁。
- [x] 记录每阶段自动检查与用户手动验收结果；延期项目未伪装为通过。
- [x] 按用户指令跳过 `nix fmt`、`boot` 和 `switch`；Flake/闭包检查由 GitHub Actions 执行。
- [x] 审查公共模块中不存在 `thinkbook14`、用户密码、硬件 UUID 或非自由全局开关等泄漏。

回滚点：文档阶段不改变运行系统；代码修正回到阶段 7 已验证提交。

阶段记录：阶段 8 已新增 [`docs/architecture.md`](../../../docs/architecture.md) 和 [`docs/operations.md`](../../../docs/operations.md)，记录架构所有权、设备扩展、输入更新、CI、部署回滚、系统代清理和 EFI 人工门禁；公共模块静态泄漏审查通过。提交 `a773768` 推送后等待 GitHub Actions 最终检查，按用户指令不执行 `nix fmt`、`boot` 或 `switch`，CI 完成后直接归档主任务。

## 最终质量门禁

```bash
git diff --check
nix flake check --no-build --show-trace
nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel --no-link --show-trace
nix eval --json .#nixosConfigurations.thinkbook14.config.system.stateVersion
nix eval --json .#nixosConfigurations.thinkbook14.config.services.displayManager.gdm.enable
nix eval --json .#nixosConfigurations.thinkbook14.config.programs.niri.enable
```

按用户指令跳过 `nix fmt`、`nixos-rebuild boot` 和 `switch`；本地没有 Nix 时由 GitHub Actions 执行 Flake 检查、配置枚举和主机闭包构建，现场会话验收保持延期记录。
