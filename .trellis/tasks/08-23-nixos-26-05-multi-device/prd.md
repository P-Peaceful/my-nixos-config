# 构建可维护的多设备 NixOS 26.05 配置仓库

## 目标

从零建立一个可长期维护、可复现、可扩展到多台设备的 NixOS 26.05 配置仓库。系统级配置与用户级配置边界清晰，首台主机 `thinkbook14` 能运行 Niri + Noctalia，并通过 GDM 提供精简 GNOME 备用会话。

## 用户价值

- 通过锁定输入重建、检查、升级和回滚系统与用户环境。
- 新设备主要组合公共模块和角色模块，无需复制整套主机配置。
- Niri 或 Noctalia 故障时，仍可通过 GDM 进入独立的 GNOME 图形会话恢复。
- 每一阶段只交付一组内聚能力，便于在唯一真实设备上定位问题和回退。

## 背景与约束

- 当前仓库没有 NixOS 或 Home Manager 配置，只有 Trellis 初始化元数据。
- 当前唯一真实设备为日常使用的 Intel Core Ultra 7 核显笔记本，主机名为 `thinkbook14`。
- 目标登录用户为 `wenzhengcheng`，主目录为 `/home/wenzhengcheng`；最终模型为一个逻辑用户跨多台设备复用配置。
- `thinkbook14` 是 Windows + NixOS 双系统，Windows 必须继续能从 NixOS 管理的引导菜单启动。
- 用户负责逐阶段完成真实硬件、引导和图形会话手动测试；自动化负责求值、格式、静态配置和构建检查。
- 用户提供由目标机器生成的 `hosts/thinkbook14/hardware-configuration.nix`；仓库不得猜测或抽象机器生成的硬件事实。
- 配置必须优先采用 NixOS 26.05、Home Manager 26.05 及各上游项目的官方模块和文档。

## 需求

### R1：输入与可复现性

- 使用 Flake 组织仓库，并通过 `flake.lock` 固定全部外部输入。
- Nixpkgs 固定到 NixOS 26.05；Home Manager 固定到 `release-26.05`，并让其 Nixpkgs 输入跟随仓库 Nixpkgs。
- Noctalia 使用 v5 官方上游 Flake，其 Nixpkgs 输入跟随仓库 Nixpkgs；不得混用 v4 `noctalia-shell` 的包、选项或配置路径。
- 仓库必须提供不切换当前系统即可执行的格式、Flake 和目标系统构建检查。
- 依赖只能通过显式更新流程升级；部署时不得追踪浮动版本。

### R2：多设备结构

- 公共系统模块、设备角色、主机配置、硬件配置、公共用户模块和主机级用户覆盖必须具有明确目录边界。
- `hardware-configuration.nix` 仅属于具体主机；主机之间不得复制大段公共配置。
- 通用笔记本能力必须由角色模块表达，`thinkbook14` 只选择角色并声明主机特有信息。
- 新设备应通过新增主机入口并组合已有模块接入；不得为尚不存在的设备伪造硬件配置。

### R3：系统与用户配置边界

- NixOS 管理引导、硬件、用户账号、显示管理器、桌面会话注册、系统服务和安全策略。
- Home Manager 作为 NixOS 模块接入，管理 `wenzhengcheng` 的用户程序、桌面外壳配置、输入法用户配置和用户文件。
- Home Manager 使用系统的同一个 Nixpkgs 实例，使用户环境与 NixOS 系统代一起构建、部署和回滚。
- `system.stateVersion` 与 `home.stateVersion` 均固定为 `26.05`，后续依赖升级不得顺带修改。

### R4：账号与安全边界

- NixOS 声明普通用户 `wenzhengcheng`，并加入 `wheel` 与 `networkmanager` 组。
- sudo 必须要求用户密码，不得启用免密提权；GDM 必须禁用自动登录。
- 用户密码保持机器本地可变状态，不得把明文密码、初始密码、密码哈希或私钥写入仓库或 Nix Store。
- 当前任务不引入 SOPS、age 或其他声明式秘密管理系统。
- 默认禁止非自由软件，不启用全局 `allowUnfree`；未来只能按明确需求单独评审和放行。

### R5：引导与回滚

- `thinkbook14` 使用 systemd-boot，并在部署前确认目标以 UEFI 启动且 EFI 系统分区挂载点与 NixOS 配置一致。
- 引导菜单必须包含 Windows、当前 NixOS 系统代和受限数量的旧 NixOS 系统代。
- Windows 与 NixOS 使用同一 EFI 系统分区时优先依赖 systemd-boot 自动发现；若不在同一 EFI 系统分区，则仅采用 NixOS 官方文档支持的链式启动方案。
- `boot.loader.systemd-boot.configurationLimit` 必须显式设置，避免 EFI 系统分区被旧内核和 initrd 占满。
- 文档必须区分 `nixos-rebuild build`、`test`、`boot` 和 `switch`，并提供系统代回滚与清理流程。

### R6：桌面与恢复

- GDM 是唯一显示管理器，禁用自动登录，并同时注册 Niri 主会话与 GNOME 备用会话。
- GNOME 备用会话不得依赖 Niri 或 Noctalia，关闭 GNOME 核心应用集合，只保留可靠恢复所需的 Shell、控制中心、文件管理等基础能力。
- Niri 使用 NixOS 26.05 官方模块及锁定版本的官方默认配置，不复制完整默认配置，不自定义布局、快捷键或窗口规则。
- Noctalia 使用 v5 官方 Home Manager 模块及锁定版本的官方默认配置，不自定义主题、插件或组件编排。
- Noctalia 用户服务只能在 Niri 会话中启动，不得随 GNOME 备用会话启动。
- 仓库只声明 Niri、Noctalia、GDM、门户、输入法和会话启动正常协作所需的最小集成项。
- 首版补充 Niri 官方默认快捷键依赖的终端和备用启动器；浏览器、编辑器、开发工具和其他个人应用不纳入本任务。

### R7：区域、输入与笔记本服务

- 时区为 `Asia/Shanghai`；默认区域为 `en_US.UTF-8`，同时启用 `zh_CN.UTF-8`；键盘采用美式布局。
- 中文输入使用 Fcitx5 + Rime，并在 Niri 与 GNOME 中可用。
- 通用笔记本角色启用 NetworkManager、PipeWire 的 PulseAudio 兼容层、Bluetooth、UPower、Power Profiles Daemon、Polkit 和 fwupd。
- 未确认硬件与需求前，不启用指纹、打印或 Thunderbolt 授权服务；GNOME 模块产生的相关默认值必须按此边界复核。

### R8：严格分阶段交付

- 每个阶段只能引入一组内聚能力，必须通过自动检查并由用户完成该阶段手动验收后，才能开始下一阶段。
- 阶段失败时回退到上一个已验证系统代；不得把仓库骨架、Home Manager、桌面会话和 Noctalia 一次性实现。
- 每个阶段必须记录自动检查、手动检查、官方依据、已知风险和回滚点。

## 验收标准

- [ ] AC1：Flake 输入全部锁定；`nix flake check` 和 `thinkbook14` 系统闭包构建在不切换当前系统的情况下通过。
- [ ] AC2：目录结构清楚区分公共模块、笔记本角色、`thinkbook14` 主机、机器生成硬件配置、公共用户配置和主机用户覆盖。
- [ ] AC3：`networking.hostName` 为 `thinkbook14`；NixOS 与 Home Manager 的目标用户均为 `wenzhengcheng`，Home Manager 随系统代部署。
- [ ] AC4：仓库不包含密码、密码哈希或私钥；用户可用本地密码登录并在输入密码后使用 sudo；无密码 sudo 和 GDM 自动登录均被禁用。
- [ ] AC5：配置在不启用全局 `allowUnfree` 的条件下完成求值与构建。
- [ ] AC6：systemd-boot 能启动当前及受保留的旧 NixOS 系统代，Windows 入口直接出现在菜单中，并由用户验证三类入口均可启动。
- [ ] AC7：NetworkManager、PipeWire、Bluetooth、UPower、Power Profiles Daemon、Polkit 和 fwupd 可用；未经确认的指纹、打印与 Thunderbolt 授权服务未被启用。
- [ ] AC8：GDM 可分别登录 Niri 和 GNOME；Noctalia 不在 GNOME 中启动，停用或破坏 Noctalia 配置后，GNOME 仍能独立进入并完成基本恢复操作。
- [ ] AC9：Niri 与 Noctalia 使用官方默认配置，无自定义布局、快捷键、窗口规则、主题、插件或组件编排；所需终端与备用启动器可用。
- [ ] AC10：Niri 与 GNOME 均可输入英文并通过 Fcitx5 + Rime 输入中文，系统时间使用 `Asia/Shanghai`。
- [ ] AC11：文档覆盖仓库结构、新增设备、依赖更新、静态检查、构建、部署、系统代回滚和清理，并区分自动检查与真实设备手动验收。
- [ ] AC12：阶段记录证明每一阶段均在下一阶段开始前完成自动检查和用户确认。

## 暂不纳入范围

- 第二台设备的真实硬件适配，以及同一设备上的多用户 Home Manager 模型。
- SOPS、age、Secure Boot、Impermanence、Disko 或其他额外基础设施。
- 指纹识别、打印、Thunderbolt 授权及未经确认的硬件功能。
- Niri/Noctalia 个性化、主题、插件、应用配色联动和个人快捷键。
- 浏览器、编辑器、开发工具、游戏及其他个人应用。
- 服务器服务、自托管应用或家庭实验室编排。

## 官方依据

- NixOS 26.05 手册：<https://nixos.org/manual/nixos/stable/>
- NixOS 26.05 Niri 模块：<https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/programs/wayland/niri.nix>
- NixOS 26.05 输入法模块：<https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/i18n/input-method/default.nix>
- NixOS 26.05 GNOME 模块：<https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/services/desktop-managers/gnome.nix>
- Home Manager Flake 与 NixOS 模块文档：<https://nix-community.github.io/home-manager/nix-flakes.html>、<https://nix-community.github.io/home-manager/installation/nixos.html>
- Niri 入门文档：<https://github.com/niri-wm/niri/wiki/Getting-Started>
- Noctalia v5 NixOS 文档与上游 Flake：<https://docs.noctalia.dev/noctalia/getting-started/nixos/>、<https://github.com/noctalia-dev/noctalia/blob/main/flake.nix>
