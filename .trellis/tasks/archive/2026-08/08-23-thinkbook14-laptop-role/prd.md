# thinkbook14 通用笔记本角色

## 目标与依赖

作为父任务阶段 3，在已完成的 `thinkbook14` 核心系统闭包上增加与桌面无关的通用笔记本系统服务。该任务只管理系统级服务，不创建硬件配置、不生成 `flake.lock`，也不加入 Home Manager 或图形桌面。

## 范围

- 创建可复用的 `modules/nixos/roles/laptop.nix`。
- 在 `thinkbook14` 主机入口导入该角色。
- 启用 NetworkManager、PipeWire 的 PulseAudio 兼容层、Bluetooth、UPower、Power Profiles Daemon、Polkit 和 fwupd。
- 显式保持指纹、打印和 Bolt/Thunderbolt 授权服务关闭。
- 通过静态检查、Flake 求值和系统闭包构建验证最终服务开关；不自动切换系统。

## 明确不包含

- GDM、GNOME、Niri、Noctalia、Home Manager、Fcitx5 或其他用户级能力。
- 磁盘、文件系统、硬件 UUID、EFI、Windows 引导和设备专属内核参数。
- 指纹、打印、Thunderbolt 授权服务，以及未由本阶段需求证明必要的额外服务。
- `nixos-rebuild boot`、`switch`、现场设备部署或破坏性修改。

## 自动验收标准

- [ ] `nix flake check` 通过。
- [ ] `nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel` 通过。
- [ ] 求值确认 NetworkManager、PipeWire/PulseAudio、Bluetooth、UPower、Power Profiles Daemon、Polkit 和 fwupd 已启用。
- [ ] 求值确认指纹、打印和 Bolt/Thunderbolt 授权保持关闭。
- [ ] 静态检查确认未加入桌面、Home Manager、输入法或硬件事实。
- [ ] 当前环境没有 Nix 时，以上命令标记为“待目标 NixOS 执行”。

## 手动验收

在具备目标设备和 Nix 环境后，由用户验证网络连接、音频输出、蓝牙、电池状态、性能模式和 fwupd 服务；本任务不自动执行部署。

## 回滚

从阶段 2 的上一已验证系统代启动；不删除硬件或 EFI 文件。
