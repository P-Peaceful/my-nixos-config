# thinkbook14 核心系统与引导

## 目标与用户价值

作为父任务阶段 2，为唯一真实设备 `thinkbook14` 建立不含图形桌面和笔记本服务的可构建 NixOS 核心系统闭包，并声明可回滚的 systemd-boot 双系统引导基础。交付物必须支持构建和求值检查，但不自动切换当前运行系统。

## 已确认事实与依赖

- 父任务为 `.trellis/tasks/08-23-nixos-26-05-multi-device`，阶段 1 的仓库骨架和边界已获用户确认。
- 目标主机名为 `thinkbook14`，目标用户为 `wenzhengcheng`；本阶段只声明账号和 sudo 策略，不声明密码或密码哈希。
- 目标设备是 Windows + NixOS 双系统，Windows 必须继续可从引导菜单启动。
- 本子任务明确不要求、不创建也不导入 `hosts/thinkbook14/hardware-configuration.nix`；主机入口保持为不含机器文件系统事实的通用配置。
- 本子任务明确不要求、不生成 `flake.lock`；接受 Flake 输入未锁定带来的可复现性边界，验证以当前可解析的输入为准。
- 本子任务不执行真实设备部署，因此不读取或猜测 EFI 分区、UEFI 启动模式和 Windows EFI 文件位置。

## 本阶段范围

- 创建核心系统模块、`thinkbook14` 主机入口和 `nixosConfigurations.thinkbook14`。
- 声明主机名、`system.stateVersion`、Nix 设置、区域、键盘、用户和 sudo 策略。
- 启用 systemd-boot、EFI 变量写入，并将 `configurationLimit` 显式设置为 `10`。
- 构建系统闭包并执行 Flake、求值和静态边界检查，但不自动切换系统或写入 EFI。
- 保留 systemd-boot 声明作为配置契约；真实设备引导菜单、系统代和 Windows 入口验证延后到包含硬件集成的后续工作。

## 明确不包含

- 阶段 3 的通用笔记本角色及 NetworkManager、音频、蓝牙、电源、固件等服务。
- Home Manager、Fcitx5、GDM、GNOME、Niri、Noctalia 或其他图形桌面能力。
- 磁盘分区、安装、重装、迁移或硬件配置生成流程。
- 真实硬件配置导入、EFI 分区探测、systemd-boot 安装和现场启动验证。
- 自动执行 `nixos-rebuild switch`、修改当前运行系统或写入未经确认的 EFI 路径。

## 自动验收标准

- [ ] `nix flake check` 通过。
- [ ] `nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel` 通过。
- [ ] `nix eval --raw .#nixosConfigurations.thinkbook14.config.networking.hostName` 输出 `thinkbook14`。
- [ ] 最终配置包含 systemd-boot、EFI 变量写入和 `configurationLimit = 10`。
- [ ] 最终配置不启用阶段 3 或之后的服务与桌面能力。
- [ ] 若验证环境没有 Nix，以上命令标记为“待目标 NixOS 执行”，不得标记为通过；不以缺少 `flake.lock` 为失败条件。

## 延后验收

以下验收不属于本子任务，因为本任务不导入机器硬件事实，也不执行真实设备部署：

- 目标 UEFI 模式、EFI 系统分区和 Windows EFI 文件位置；
- 当前及旧 NixOS 系统代启动；
- Windows systemd-boot 菜单入口启动。

## 回滚与风险边界

本子任务不修改运行系统、EFI 分区或 Windows 文件，因此没有现场回滚动作。配置构建失败时回退代码变更即可；后续硬件集成仍须保留上一已验证的 NixOS 系统代。

## 规划状态

需求、范围、验收和风险已收敛；复杂任务的技术设计和实施清单见同目录 `design.md` 与 `implement.md`。当前仍处于 `planning`，须在用户审阅本次更新后的规划摘要并明确批准后才能激活实施阶段。
