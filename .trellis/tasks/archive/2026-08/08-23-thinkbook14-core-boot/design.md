# thinkbook14 核心系统与引导：技术设计

## 1. 架构边界

本阶段只建立系统核心和主机引导组合，保持 Flake、公共核心模块、主机入口和机器生成硬件配置的职责分离：

```text
flake.nix
  └─ nixosConfigurations.thinkbook14
       ├─ hosts/thinkbook14/default.nix       # 主机身份、引导和组合
       └─ modules/nixos/core/default.nix      # 跨设备核心系统约束
```

不得在公共核心模块中引用 `thinkbook14`、具体 UUID、磁盘路径、EFI 路径或个人凭据；不得把核心配置堆入 `flake.nix`。

## 2. Flake 输出与输入边界

- 保留现有 `nixpkgs`、Home Manager 和 Noctalia 输入及其 `follows` 关系，不为本阶段引入新输入。
- 在 Flake 边界用 `nixpkgs.lib.nixosSystem` 构造 `nixosConfigurations.thinkbook14`。
- 传入目标系统的模块只包括核心模块和 thinkbook14 主机入口；不接入硬件配置、Home Manager 或任何桌面模块。
- 保留现有 formatter 输出，并让最终验证使用锁定输入中的实际选项定义。

本子任务不生成 `flake.lock`，因此这里的“实际选项定义”来自当前可解析的 Flake 输入；可复现锁定由父任务或后续发布流程另行决定。

## 3. 核心模块职责

核心模块聚合以下最小能力：

- Nix：启用 `nix-command` 与 `flakes`，保持非自由软件默认禁止。
- 系统身份：主机名由主机入口声明；`system.stateVersion` 固定为 `26.05`。
- 区域：时区 `Asia/Shanghai`，默认区域 `en_US.UTF-8`，额外启用 `zh_CN.UTF-8`，键盘使用美式布局。
- 用户：声明普通用户 `wenzhengcheng`，加入 `wheel`；不声明密码字段。
- sudo：保留密码校验，不启用免密提权。

核心模块不启用 NetworkManager、PipeWire、Bluetooth、UPower、Power Profiles Daemon、Polkit、fwupd、Home Manager、输入法或桌面服务。

## 4. 主机入口与引导

`hosts/thinkbook14/default.nix` 只导入核心模块，并声明：

- `boot.loader.systemd-boot.enable = true`；
- `boot.loader.efi.canTouchEfiVariables = true`；
- `boot.loader.systemd-boot.configurationLimit = 10`。

本子任务不声明或猜测 EFI 分区、Windows loader 路径或链式启动 UUID，也不执行部署；真实 EFI 信息和 Windows 自动发现属于后续硬件集成工作。

## 5. 配置数据流与合同

```text
flake 输入 → nixpkgs → nixosSystem
                         ├─ core 模块 → 通用系统选项
                         └─ thinkbook14 入口 → 主机身份与 systemd-boot
                                   ↓
                         system.build.toplevel
```

自动检查只证明 Flake 输出可求值、系统闭包可构建和关键选项符合契约；UEFI、Windows 菜单、系统代启动等事实不由本子任务覆盖，留待后续硬件集成。

## 6. 兼容性、回滚与风险

- NixOS 26.05 的选项名称以当前 Flake 输入实际解析结果为准；本子任务接受不生成 `flake.lock` 的可复现性取舍。
- 不创建、不导入硬件配置，也不以空文件或猜测文件系统替代真实硬件事实。
- 不执行 `switch` 或直接 EFI 写入；真实设备回滚由后续硬件集成任务负责。
