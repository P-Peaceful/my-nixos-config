# Home Manager 26.05 与 Fcitx5 接口核对

## 核对范围

核对目标是确认本任务实现时不能凭旧版本猜测的 Home Manager NixOS 接线和 Fcitx5 用户模块选项。核对分支为 `release-26.05`，NixOS 分支为 `nixos-26.05`；最终仍须在实际 `flake.lock` 输入上用 `nix eval` 复核。

## 已确认接口

- Home Manager NixOS 模块提供 `home-manager.useGlobalPkgs` 和 `home-manager.useUserPackages`；前者复用系统 `pkgs`，后者把 Home Manager 用户包接入 NixOS 用户包路径。
- Home Manager Fcitx5 模块使用 `i18n.inputMethod.enable = true` 与 `i18n.inputMethod.type = "fcitx5"`。
- Home Manager Fcitx5 附加组件选项为 `i18n.inputMethod.fcitx5.addons`，类型是软件包列表；本任务只加入 `pkgs.fcitx5-rime`。
- Fcitx5 模块在启用时自动提供 `systemd.user.services.fcitx5-daemon`，挂接 `graphical-session.target`，因此本任务不需要自定义 systemd unit。
- 未设置 `waylandFrontend`、`settings`、`themes`、`quickPhrase` 或 `quickPhraseFiles` 时，不引入本任务禁止的自定义布局、快捷键、主题或词库内容。
- NixOS 26.05 的系统输入法接口为 `i18n.inputMethod.enable` 与 `i18n.inputMethod.type`；旧的 `i18n.inputMethod.enabled` 已标记为弃用。本任务不在 NixOS 层重复配置 Fcitx5，避免和 Home Manager 形成两个所有者。

## 官方来源

- Home Manager Fcitx5 模块：<https://github.com/nix-community/home-manager/blob/release-26.05/modules/i18n/input-method/fcitx5.nix>
- Home Manager NixOS 公共模块：<https://github.com/nix-community/home-manager/blob/release-26.05/nixos/common.nix>
- NixOS 26.05 输入法模块：<https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/i18n/input-method/default.nix>

## 限制

当前工作区没有 `nix`、`nixos-rebuild` 或 `flake.lock`，因此本文件只记录上游接口核对结果，不替代目标 NixOS 环境中的求值、格式检查和系统闭包构建。
