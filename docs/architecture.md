# NixOS 配置架构与扩展边界

## 当前范围

仓库当前只有 `thinkbook14` 一个主机输出。阶段 1–7 已完成代码接线并按用户指令归档；现场登录、输入法、桌面外壳和 EFI 操作没有在本工作区执行。新增设备必须先补充真实硬件事实，不能用本文件或公共模块推断。

## 目录与配置所有权

```text
flake.nix
├── hosts/<主机名>/                 # 主机身份、硬件文件、角色组合
├── modules/nixos/core/              # 所有设备共享的系统约束
├── modules/nixos/roles/             # 与桌面无关的可复用设备角色
├── modules/nixos/desktop/           # GDM/GNOME、Niri 等系统级会话
├── modules/home/                    # 用户级可复用能力
├── home/<用户名>/                   # 用户组合、Home Manager 状态和输入法
├── docs/                            # 架构与运维文档
└── .trellis/tasks/                  # 阶段计划、验收、归档和研究记录
```

| 配置层 | 唯一所有者 | 允许内容 | 禁止内容 |
| --- | --- | --- | --- |
| `flake.nix` | Flake | 输入、`follows`、输出、formatter、模块接线 | 主机业务逻辑、硬件事实 |
| `hosts/<主机名>` | 主机入口 | hostname、stateVersion、硬件文件、角色和桌面组合 | 复制公共服务实现 |
| `modules/nixos/core` | 系统核心 | 区域、用户、Nix 策略、通用安全边界 | 主机名、磁盘 UUID |
| `modules/nixos/roles` | 可复用角色 | 网络、音频、电源、蓝牙、固件等通用服务 | 桌面会话、用户配置 |
| `modules/nixos/desktop` | 系统会话 | GDM/GNOME、Niri、门户和恢复能力 | Home Manager 输入法、个人主题 |
| `modules/home` | Home Manager 模块 | 用户服务和用户级桌面能力 | NixOS 系统服务的重复声明 |
| `home/<用户名>` | 用户入口 | `home.stateVersion`、Fcitx5、已批准用户模块 | 密码、硬件事实、未批准个性化配置 |

## 当前主机数据流

```text
flake.nix
  → nixosConfigurations.thinkbook14
  → core + laptop role + GDM/GNOME + Niri
  → Home Manager + Fcitx5/Rime + Noctalia v5
  → GDM 选择 GNOME 恢复会话或 Niri 会话
  → Noctalia 仅在 Niri 会话环境条件满足时启动
```

Niri 和 Noctalia 是分层能力：Niri 负责系统级 Wayland 会话，Noctalia 负责用户级外壳。GNOME 保留为恢复入口，Noctalia 服务不得无条件污染 GNOME。

## 新增设备流程

1. 收集设备型号、启动模式、真实分区布局、EFI 挂载点、Windows loader 位置和 NixOS 生成的 `hardware-configuration.nix`。
2. 创建 `hosts/<新主机名>/`，只写主机身份、硬件文件和已存在的公共角色；不要复制 `thinkbook14` 字符串到公共模块。
3. 在 Flake 中增加一个明确的 `nixosConfigurations.<新主机名>` 输出，并复用同一 Nixpkgs、Home Manager 和 Noctalia 输入。
4. 先运行 Flake 求值、配置枚举和新主机闭包构建；CI 通过后再安排现场 `boot` 或 `switch` 门禁。
5. 现场部署前记录上一系统代、回滚路径和 EFI 写入授权；不得让新设备事实反向修改公共角色合同。

## 不变量

- 公共模块不能出现 `thinkbook14`、用户密码、硬件 UUID、绝对设备路径或猜测的 EFI 文件名。
- `allowUnfree` 保持关闭；新增硬件能力必须单独评估，不得用全局开关掩盖构建错误。
- Home Manager 是 Fcitx5 和 Noctalia 用户服务的唯一用户级配置层；NixOS 模块不能复制同名守护进程。
