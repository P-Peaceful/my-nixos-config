# thinkbook14 通用笔记本角色：技术设计

## 模块边界

```text
hosts/thinkbook14/default.nix
  ├─ modules/nixos/core
  └─ modules/nixos/roles/laptop.nix
       ├─ 网络：NetworkManager
       ├─ 音频：PipeWire + PulseAudio 兼容层
       ├─ 设备：Bluetooth、UPower、Power Profiles Daemon
       └─ 系统服务：Polkit、fwupd
```

`laptop.nix` 只能包含跨设备通用的服务开关，不读取主机名、硬件 UUID 或具体设备路径。主机入口只负责导入角色，不复制服务配置。

## 服务合同

- `networking.networkmanager.enable = true`。
- `services.pipewire.enable = true`，并启用 `services.pipewire.pulse` 兼容层。
- `hardware.bluetooth.enable = true`。
- 启用 `services.upower`、`services.power-profiles-daemon`、`security.polkit` 和 `services.fwupd`。
- 显式关闭 `services.fprintd`、`services.printing` 和 `services.hardware.bolt`，具体选项以锁定/当前 Nixpkgs 实际接口为准。
- 不在角色中设置音频硬件、无线网卡、固件设备路径或用户服务。

## 数据流与验证

```text
flake 输入 → core 模块 + laptop 角色 → thinkbook14 system.build.toplevel
                                       └→ 服务选项求值与闭包构建
```

自动验证证明配置合同和闭包可构建；网络、音频、蓝牙、电池、性能模式和固件实际工作情况必须由用户现场验证。

## 风险与回滚

- NixOS 选项名称必须以当前 Flake 输入实际解析结果为准；没有 Nix 时不声称构建通过。
- 如果某个服务选项在目标输入中不存在，停止实现并根据目标 Nixpkgs 接口修正，不添加兼容猜测。
- 服务导致系统不可用时，启动阶段 2 系统代；本任务不执行 `switch`，不直接修改 EFI。
