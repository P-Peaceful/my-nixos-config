# thinkbook14 通用笔记本角色：实施清单

## 实施前门禁

- [ ] 确认阶段 2 核心主机入口存在，且不引入硬件配置或 `flake.lock`。
- [ ] 阅读 `.trellis/spec/nix/` 规范和父任务官方模块研究。
- [ ] 确认本阶段不加入桌面、Home Manager、输入法和用户级服务。

## 有序实施步骤

1. 创建 `modules/nixos/roles/laptop.nix`，只声明通用笔记本系统服务。
2. 在 `hosts/thinkbook14/default.nix` 导入 laptop 角色，不复制服务选项。
3. 对排除项进行显式求值或静态审查，确认指纹、打印和 Bolt/Thunderbolt 授权未启用。
4. 检查最终配置没有新增硬件事实、EFI 路径、桌面能力或阶段 4 之后内容。

## 自动验证

```sh
nix fmt -- --check .
nix flake check
nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel
nix eval --json .#nixosConfigurations.thinkbook14.config.networking.networkmanager.enable
```

另外求值以下服务的 enable 状态，并记录结果：NetworkManager、PipeWire、Bluetooth、UPower、Power Profiles Daemon、Polkit、fwupd、fprintd、printing 和 Bolt。

没有 Nix 时，格式、Flake、构建和求值命令全部记录为“待目标 NixOS 执行”。

## 手动验收与回滚

- 用户在目标设备验证网络、音频、蓝牙、电池、性能模式和 fwupd。
- 不执行 `nixos-rebuild switch`；验证失败时从阶段 2 的已验证系统代回滚。
