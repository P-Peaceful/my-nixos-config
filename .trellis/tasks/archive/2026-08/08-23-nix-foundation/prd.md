# 仓库与 Nix 规范基础

## 目标

为后续分阶段构建 NixOS 仓库建立可复现的输入基线、Nix 项目规范和最小 Flake 骨架。本阶段不产生可部署的 NixOS 主机配置。

## 上游依赖

- 父任务：`.trellis/tasks/08-23-nixos-26-05-multi-device`
- 只执行父任务 `implement.md` 的“阶段 1：仓库与 Nix 规范基础”。
- 后续所有主机、Home Manager、GDM、GNOME、Niri 和 Noctalia 实现均依赖本阶段通过。

## 范围

- 建立真实的 Nix/NixOS 项目规范，使后续实现和检查不再使用通用前后端占位约定。
- 创建最小 `flake.nix`，声明 Nixpkgs 26.05、Home Manager `release-26.05` 与 Noctalia v5 官方输入。
- 让 Home Manager 和 Noctalia 的 Nixpkgs 输入跟随仓库 Nixpkgs。
- 暴露 `x86_64-linux` 格式化器，但不引入 flake-utils、flake-parts、treefmt 等额外框架。
- 生成并提交 `flake.lock`。
- 创建简短 README，说明仓库当前仅完成阶段 1、输入策略、检查命令和阶段 2 前置条件。

## 明确不包含

- `nixosConfigurations` 或任何可部署系统闭包。
- `hosts/`、`modules/`、`home/` 下的 NixOS/Home Manager 实现。
- systemd-boot、用户、笔记本服务、GDM、GNOME、Niri、Fcitx5 或 Noctalia 启用配置。
- 为缺失的 `hardware-configuration.nix` 创建占位或伪造内容。
- 个人应用、主题、插件和设备特定设置。

## 验收标准

- [ ] Nix 项目规范具有明确目录、模块边界、命名、格式、输入锁定、验证和反模式约束，并引用父任务的官方研究。
- [ ] `flake.nix` 只声明三个批准输入、跟随关系、支持系统和 formatter，不包含主机实现。
- [ ] `flake.lock` 固定全部输入的精确修订。
- [ ] README 明确当前阶段边界和下一阶段所需的真实硬件文件。
- [ ] 在可用 Nix 环境中，`nix flake metadata`、`nix flake check` 和格式检查通过。
- [ ] 若当前环境没有 Nix，检查必须明确标记为“待目标 NixOS 执行”，不得虚报通过。
- [ ] 阶段 2 及之后的文件和功能均未提前创建。

## 回滚

删除本阶段新增的 Nix 规范、`flake.nix`、`flake.lock` 与 README，即可回到 Trellis-only 仓库，不影响任何运行系统。

