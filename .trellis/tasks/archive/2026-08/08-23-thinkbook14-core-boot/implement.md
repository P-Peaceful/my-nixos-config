# thinkbook14 核心系统与引导：实施清单

## 实施前门禁

- [x] 确认本子任务不创建、不导入 `hardware-configuration.nix`。
- [x] 确认本子任务不生成 `flake.lock`，验证基于当前可解析的 Flake 输入。
- [x] 确认当前任务仍为阶段 2，未把阶段 3、Home Manager 或桌面功能带入实现。

## 有序实施步骤

1. [x] 创建 `modules/nixos/core/` 和 `hosts/thinkbook14/` 的最小目录及模块入口，不创建或导入硬件文件。
2. [x] 编写核心系统模块，声明 Nix 设置、区域、键盘、`system.stateVersion`、用户和密码 sudo 策略。
3. [x] 编写 thinkbook14 主机入口，仅导入核心模块，并声明 systemd-boot、EFI 变量写入及 `configurationLimit = 10`。
4. [x] 扩展 `flake.nix` 输出 `nixosConfigurations.thinkbook14`，保持既有输入、跟随关系和 formatter 不变。
5. [x] 对最终模块组合执行静态范围审查，确认不存在桌面、Home Manager、输入法、笔记本服务、密码、猜测 UUID 或未经确认的 EFI 路径。

README 已同步更新为阶段 2 状态。

## 自动验证

在具备目标 Nix 环境后按以下顺序执行：

```sh
nix fmt -- --check .
nix flake check
nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel
nix eval --raw .#nixosConfigurations.thinkbook14.config.networking.hostName
```

额外静态断言：

- `networking.hostName` 为 `thinkbook14`；
- `system.stateVersion` 为 `26.05`；
- `boot.loader.systemd-boot.enable` 和 `boot.loader.efi.canTouchEfiVariables` 为真；
- `boot.loader.systemd-boot.configurationLimit` 为 `10`；
- 阶段 3 及之后服务和桌面选项未被启用。

本地静态契约断言和 `git diff --check` 已通过。

没有 Nix 时，格式、Flake、构建和求值命令全部记录为“待目标 NixOS 执行”；缺少 `flake.lock` 不作为本子任务失败条件。

## 后续硬件集成（不在本子任务执行）

- 真实设备部署前再确认 UEFI 模式、EFI 系统分区和 Windows EFI 文件。
- 后续任务负责硬件配置导入、systemd-boot 安装、Windows 自动发现和系统代现场验证。
- 本子任务只保证声明可被检查和构建，不执行 `nixos-rebuild boot` 或 `switch`。

## 回滚点与交付检查

- 本子任务不修改运行系统或 EFI 文件，回滚点为代码变更本身；后续硬件集成仍须保留上一已验证的 NixOS 系统代。
- 自动检查完成后记录结果；本子任务明确延后的现场验收由后续硬件集成任务负责，再等待父任务阶段推进。
- 若任一硬件、EFI 或系统代验证失败，保留代码和现有系统代，修正后重新执行本清单，不扩大阶段范围。
