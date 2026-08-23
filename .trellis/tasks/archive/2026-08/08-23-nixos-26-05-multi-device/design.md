# 技术设计

## 1. 设计目标

以最少的自定义抽象建立 Flake 驱动的多设备 NixOS 仓库。首台主机 `thinkbook14` 是唯一部署目标，但目录和模块所有权从第一天起支持后续添加设备。桌面链路按 GDM → Niri → Noctalia 分层，GNOME 始终作为独立恢复会话存在。

## 2. 仓库边界

```text
flake.nix
flake.lock
README.md
hosts/
  thinkbook14/
    default.nix
    hardware-configuration.nix
modules/
  nixos/
    core/
      default.nix
      locale.nix
      nix-settings.nix
      users.nix
    roles/
      laptop.nix
    desktop/
      gdm-gnome.nix
      niri.nix
  home/
    core.nix
    input/
      fcitx5.nix
    desktop/
      noctalia.nix
home/
  wenzhengcheng/
    default.nix
docs/
  architecture.md
  operations.md
  stages.md
```

### 所有权规则

- `flake.nix` 只负责输入、外部模块接线、系统输出与格式化器，不承载主机业务配置。
- `hosts/<name>/` 只保存主机身份、引导选择、硬件文件和角色组合。
- `modules/nixos/core/` 保存所有设备都应具备的系统约束。
- `modules/nixos/roles/` 保存可复用设备角色；不得引用具体主机名或硬件 UUID。
- `modules/nixos/desktop/` 保存系统级会话注册、门户和恢复能力。
- `modules/home/` 保存可跨设备复用的用户能力。
- `home/<user>/` 组合用户模块，并作为后续主机级用户覆盖的入口。
- 不为单次引用提前创建通用 helper；出现第二个真实主机并产生重复后再提取构造函数。

## 3. Flake 与输入

### 输入

- `nixpkgs`：`github:NixOS/nixpkgs/nixos-26.05`
- `home-manager`：`github:nix-community/home-manager/release-26.05`，跟随 `nixpkgs`
- `noctalia`：`github:noctalia-dev/noctalia`，跟随 `nixpkgs`

### 输出

- `nixosConfigurations.thinkbook14`
- `formatter.x86_64-linux`，使用锁定 Nixpkgs 中的官方 Nix 格式化器
- 必要的 Flake checks；不引入 flake-utils、flake-parts 或 treefmt 等额外框架

外部模块在 Flake 边界接入：

- `home-manager.nixosModules.home-manager`
- `noctalia.homeModules.default` 通过 Home Manager 的共享模块或目标用户 imports 注入

不把完整 `inputs` 传播给所有模块。只有确实需要外部值的边界模块接收精确参数，降低隐式耦合。

## 4. NixOS 模块组合

`hosts/thinkbook14/default.nix` 导入：

1. 用户提供的 `hardware-configuration.nix`
2. core 聚合模块
3. laptop 角色
4. GDM/GNOME 恢复模块
5. Niri 模块
6. `home/wenzhengcheng/default.nix` 的 Home Manager 接线

### Core

- 主机名由主机模块设置为 `thinkbook14`。
- Nix 启用 `nix-command` 与 `flakes`，但不设置非必要实验选项。
- 默认禁止非自由软件。
- 时区、区域、键盘、用户、sudo 和 state version 由 core 管理。
- 账号不声明密码字段，保留机器本地可变密码。

### 引导

- 引导配置归属 `hosts/thinkbook14/default.nix`，不进入公共 laptop 角色。
- 启用 systemd-boot、EFI 变量写入和明确的系统代数量上限；初始上限采用 10，若目标 EFI 分区空间不足则在该主机内下调。
- 部署前门禁验证 UEFI、EFI 挂载点与 Windows EFI 位置。
- Windows 未自动出现时暂停该阶段，只在获得真实设备信息后添加官方链式启动条目。

### Laptop 角色

- NetworkManager、PipeWire/PulseAudio 兼容、Bluetooth、UPower、Power Profiles Daemon、Polkit、fwupd。
- 显式保持打印、指纹和 Bolt/Thunderbolt 授权关闭。
- 不写 Intel Core Ultra 专属内核参数；真实需要必须由手动测试证据触发并放入主机模块。

## 5. Home Manager

- 作为 NixOS 模块集成，`useGlobalPkgs = true`、`useUserPackages = true`。
- 只配置用户 `wenzhengcheng`。
- `home/core.nix` 声明用户名、主目录和 `home.stateVersion`。
- Fcitx5 与 Noctalia 均由 Home Manager 用户模块管理，避免系统层和用户层重复所有权。

### Fcitx5

- Home Manager 启用 Fcitx5、systemd 用户服务和 `fcitx5-rime`。
- 保持 Home Manager 官方会话变量与默认设置，不写自定义主题、词库或快捷键。
- NixOS 层显式关闭 GNOME 默认的 IBus 输入法，使 Fcitx5 成为唯一输入法守护进程。

### Noctalia

- 导入官方 v5 Home Manager 模块。
- 只设置 `programs.noctalia.enable = true` 与 `systemd.enable = true`。
- 不设置 `settings`、`customPalettes` 或插件，从而使用上游默认配置。
- 保留官方 systemd 用户服务，并添加基于 Niri 会话环境的最小启动条件；这样无需修改 Niri 默认配置，也不会在 GNOME 恢复会话启动 Noctalia。

## 6. 桌面与恢复链路

### GDM/GNOME

- GDM 是唯一显示管理器，不启用自动登录。
- 启用 GNOME 会话，显式关闭 `services.gnome.core-apps.enable`。
- 保留恢复所需的 GNOME Shell、控制中心、Nautilus 与门户。
- 检查 GNOME 模块默认值，显式关闭 IBus、Bolt、打印以及未授权范围。

### Niri

- 使用 NixOS 26.05 的 `programs.niri.enable`，让官方模块注册会话、门户和 Keyring。
- 不创建 `~/.config/niri/config.kdl` 或 `/etc/niri/config.kdl`；Niri 首次启动使用锁定二进制内嵌的官方默认配置。
- 安装 Alacritty 与 Fuzzel 以满足默认快捷键；安装 `xwayland-satellite` 以遵循上游兼容建议。
- 不安装 Waybar，避免与 Noctalia 的状态栏重叠；默认配置尝试启动不存在的 Waybar 时应只产生可解释日志，不影响会话。

## 7. 验证数据流

```text
flake.lock
   │
   ├─ nixpkgs 26.05 ──> nixosSystem ──> thinkbook14 system closure
   │                                      │
   ├─ Home Manager 26.05 ─────────────────┤
   │                                      └─ wenzhengcheng home activation
   └─ Noctalia v5 home module ───────────────> Noctalia user service

GDM ──> GNOME（独立恢复）
  └──> Niri ──> graphical-session target ──> Fcitx5 + Noctalia
```

自动检查只能证明模块求值、闭包构建和静态断言；GDM 会话、输入法、Intel 图形、Windows 引导和旧系统代回滚必须由用户在 `thinkbook14` 上验证。

## 8. 风险与缓解

| 风险 | 缓解 |
|---|---|
| Windows 位于另一 EFI 分区，systemd-boot 未自动发现 | 阶段门禁收集真实 EFI 信息，只使用官方链式启动方案 |
| GNOME 默认启用 IBus、Bolt 或其他越界服务 | 对最终合并配置做 `nix eval`，并显式覆盖不需要的默认值 |
| Noctalia v5 快速变化 | `flake.lock` 固定修订，单独更新并执行完整桌面回归 |
| Niri 默认配置生成到用户目录后不会随包更新 | 文档说明其生命周期；升级 Niri 时用户决定是否删除并重新生成默认配置 |
| Niri 默认配置引用 Waybar | 不安装 Waybar，记录预期日志；Noctalia 通过用户服务提供状态栏 |
| Noctalia 官方服务默认跟随通用图形会话 target | 增加 Niri 会话条件，并分别在 Niri/GNOME 中检查用户服务状态 |
| 唯一真实设备无法并行验证 | 每一阶段形成独立提交和系统代，用户确认后才进入下一阶段 |
| 当前 Windows 环境可能没有 Nix | 不把未运行的命令报告为通过；由目标 NixOS 设备执行构建门禁 |

## 9. 发布与回滚

- 每个阶段独立 Trellis 子任务、独立提交、独立自动检查和用户手动验收。
- 初次切换前先执行 `nixos-rebuild build`；涉及引导时先执行 `nixos-rebuild boot` 并验证菜单，再决定 `switch`。
- 桌面阶段失败时从 GDM 进入 GNOME 或 TTY；系统阶段失败时从 systemd-boot 选择上一系统代。
- 不自动删除旧系统代；清理只在新系统代和 Windows 均验证后执行。
