# 阶段 5：GDM 与精简 GNOME 技术设计

## 模块边界

```text
flake.nix
  └─ nixosConfigurations.thinkbook14
       ├─ modules/nixos/core
       ├─ modules/nixos/roles/laptop.nix
       ├─ modules/nixos/desktop/gdm-gnome.nix
       ├─ hosts/thinkbook14
       └─ Home Manager → user-level Fcitx5 + Rime
```

- `modules/nixos/desktop/gdm-gnome.nix` 只拥有显示管理器、GNOME 恢复会话和 GNOME 触发的越界默认值覆盖。
- `hosts/thinkbook14/default.nix` 只负责导入阶段模块，不复制桌面服务选项。
- `modules/nixos/roles/laptop.nix` 继续拥有跨桌面的笔记本服务；阶段 5 不修改其网络、音频、电源和蓝牙合同。
- `home/wenzhengcheng/default.nix` 继续拥有用户级 Fcitx5；阶段 5 不新增系统级 Fcitx5 守护进程或自定义输入法配置。

## 配置合同

- `services.displayManager.gdm.enable = true`。
- `services.displayManager.autoLogin.enable = false`，不设置自动登录用户。
- `services.desktopManager.gnome.enable = true`。
- `services.gnome.core-apps.enable = false`；GNOME 核心 Shell 模块仍由桌面管理器启用，并显式补充 `pkgs.nautilus` 作为恢复文件管理器。
- `i18n.inputMethod.enable = false` 覆盖 GNOME 模块的 IBus 默认值；Fcitx5 仍由 Home Manager 用户模块管理。
- `services.hardware.bolt.enable = false`、`services.printing.enable = false` 由通用笔记本角色统一持有；本模块只验证 GNOME 合并后没有用默认值覆盖该合同，并保持角色模块已有的指纹服务关闭合同。
- 不设置 `services.displayManager.defaultSession`，避免在 Niri 尚未加入时伪造最终默认桌面选择。

## 数据流与验证

```text
阶段 5 NixOS 模块
  → GNOME/GDM 会话注册
  → systemd/display-manager
  → 用户密码登录 GNOME
  → Home Manager 用户环境提供 Fcitx5 + Rime
```

自动检查应验证最终合并选项，而不是只检查新模块文本：GDM、GNOME、自动登录、core-apps、NixOS IBus、Bolt、打印和系统包均需在目标环境求值。真实设备检查负责验证密码登录、会话切换、输入法和注销回 GDM。

## 兼容性与回滚

- 选项名称和默认服务以 NixOS 26.05 锁定输入实际源码为准；官方模块研究确认 `services.gnome.core-apps.enable` 关闭的是核心应用集合，而 Shell 模块仍提供控制中心等基础能力。
- 若 GNOME 模块与阶段 4 的 Home Manager 输入法发生竞争，以最终求值和用户会话日志为准；不得通过添加第二个 Fcitx5/IBus 服务临时掩盖问题。
- 失败时从阶段 4 系统代启动，或回退本阶段模块导入；不执行现场 `switch`、引导写入或硬件变更。
