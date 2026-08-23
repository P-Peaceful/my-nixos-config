# 阶段 4：Home Manager 与 Fcitx5 实施清单

## 实施前门禁

- [ ] 阅读 `.trellis/spec/nix/` 规范和父任务官方模块研究。
- [ ] 确认阶段 3 的 laptop 角色已完成，且本阶段不扩展桌面、硬件或现场部署范围。
- [ ] 以当前 Flake 输入实际源码确认 Home Manager NixOS 模块和 Fcitx5 选项名称。
- [ ] 确认 `wenzhengcheng` 已由核心 NixOS 模块创建。
- [ ] 阅读 `research/home-manager-fcitx5-interface.md`，将上游接口核对与目标环境求值区分记录。

## 有序实施步骤

1. 修改 `flake.nix`，将 `home-manager` 输入传入 outputs，并接入 `home-manager.nixosModules.home-manager`。
2. 配置 `home-manager.useGlobalPkgs = true` 和 `home-manager.useUserPackages = true`，将用户入口挂载到 `home-manager.users.wenzhengcheng`。
3. 创建 `home/core/default.nix`，只放公共 Home Manager 基础边界。
4. 创建 `home/wenzhengcheng/default.nix`，固定 `home.stateVersion = "26.05"`，使用当前接口启用 Home Manager Fcitx5、自动 systemd 用户服务和 `fcitx5-rime`。
5. 静态审查并删除任何自定义词库、主题、布局、快捷键、桌面模块、硬件事实或重复系统级输入法配置。
6. 更新阶段文档中必要的配置入口说明，但不提前标记用户现场验收为完成。
7. 同步更新 README 的阶段状态和配置入口说明，避免文档继续声称仓库不含 Home Manager。

## 自动验证

```sh
nix fmt -- --check .
nix flake check
nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel
nix eval --json .#nixosConfigurations.thinkbook14.config.home-manager.useGlobalPkgs
nix eval --json .#nixosConfigurations.thinkbook14.config.home-manager.useUserPackages
nix eval --json .#nixosConfigurations.thinkbook14.config.home-manager.users.wenzhengcheng.home.stateVersion
```

另行求值或静态确认 Home Manager 用户配置启用 Fcitx5、包含 `fcitx5-rime`，并未加入自定义词库、主题、布局、快捷键或桌面阶段能力。没有 Nix 时，所有 Nix 命令记录为“待目标 NixOS 执行”。

## 验收与回滚

- 用户在目标设备验证 Home Manager activation、Fcitx5 + Rime 输入、用户 systemd 服务和现有系统服务不受影响。
- 不执行 `nixos-rebuild switch`、`boot` 或现场部署。
- 验证失败时从阶段 3 的已验证系统代回滚。
