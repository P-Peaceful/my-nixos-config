# 阶段 4：Home Manager 与 Fcitx5 技术设计

## 架构边界

```text
flake.nix
  ├─ home-manager 输入
  └─ nixosConfigurations.thinkbook14
       ├─ modules/nixos/core
       ├─ hosts/thinkbook14
       ├─ modules/nixos/roles/laptop.nix
       └─ home-manager.nixosModules.home-manager
            └─ home/wenzhengcheng/default.nix
                 └─ home/core/default.nix
```

- `flake.nix` 只负责传递输入、接入 Home Manager NixOS 模块和组合用户入口。
- `home/core/default.nix` 只放可跨用户复用的 Home Manager 基础契约，不引用主机名、硬件事实或个人凭据。
- `home/wenzhengcheng/default.nix` 负责用户身份、`home.stateVersion` 和本阶段批准的 Fcitx5 配置。
- Home Manager 是 Fcitx5 用户级配置的唯一所有者；NixOS 系统模块不复制用户级 Fcitx5 配置。

## 配置合同

- Home Manager 输入继续使用 `release-26.05`，并跟随根 Flake 的 `nixpkgs`。
- `home-manager.useGlobalPkgs = true`。
- `home-manager.useUserPackages = true`。
- 用户入口固定 `home.stateVersion = "26.05"`。
- Home Manager 用户输入法配置使用 `i18n.inputMethod.enable = true`、`i18n.inputMethod.type = "fcitx5"`，并只在 `i18n.inputMethod.fcitx5.addons` 加入 `pkgs.fcitx5-rime`。
- 依赖 Home Manager 自动提供的 `systemd.user.services.fcitx5-daemon`；不新增自定义 systemd unit、环境覆盖或会话脚本。
- 不设置自定义词库、主题、布局和快捷键；不得混入后续桌面阶段配置。

## 数据流与构建

```text
flake input home-manager
  → home-manager.nixosModules.home-manager
  → home-manager.users.wenzhengcheng
  → Home Manager activation package
  → thinkbook14 system.build.toplevel
```

系统闭包构建应包含 Home Manager activation package，关键求值应能证明用户配置入口和 Fcitx5 合同存在。没有 Nix 时不得把未运行的求值或构建报告为通过。

## 兼容性与风险

- Home Manager 选项名称必须以当前 `release-26.05` 输入源码为准，不凭旧版本接口猜测。
- Fcitx5 配置必须避免与未来 GNOME 阶段的 IBus 默认行为形成两个输入法守护进程竞争；本阶段只处理已批准的用户级输入法边界，桌面会话覆盖留给阶段 5。
- 现有用户必须已由核心模块创建；本阶段不创建第二个用户或修改硬件事实。

## 回滚

如果 Home Manager activation 或 Fcitx5 配置导致系统不可用，从阶段 3 已验证系统代启动；本阶段不执行部署或 EFI 修改。
