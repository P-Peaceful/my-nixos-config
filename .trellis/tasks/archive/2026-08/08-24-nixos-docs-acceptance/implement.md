# 阶段 8：文档与多设备扩展验收实施清单

## 实施前门禁

- [x] 阅读父任务阶段清单、Nix 项目规范和官方研究。
- [x] 确认阶段 5–7 已按用户指令归档，现场验收延期状态仍有记录。
- [x] 确认本阶段不新增主机、不执行 boot/switch、不写入 EFI。

## 有序实施步骤

1. [x] 创建 `docs/architecture.md`，记录架构、所有权、数据流和新增设备流程。
2. [x] 创建 `docs/operations.md`，记录输入更新、检查、构建、部署、回滚、EFI 和系统代清理。
3. [x] 更新 README 和主任务阶段清单，链接文档并整理阶段 1–7 自动/现场状态。
4. [x] 静态审查公共模块泄漏、越界服务所有权和未批准的非自由配置。
5. [x] 运行 `git diff --check`；按用户指令跳过 `nix fmt`、`nixos-rebuild boot` 和 `switch`。
6. [x] 推送文档提交，直接归档阶段 8并完成主任务清单和归档记录。

## 自动验证

```sh
git diff --check
nix flake check --no-build --show-trace
nix build .#nixosConfigurations.thinkbook14.config.system.build.toplevel --no-link --show-trace
```

本地没有 Nix；GitHub Actions 负责 Flake 检查、配置枚举和主机闭包构建。`nix fmt`、`boot`、`switch` 和现场会话测试按用户指令延期。

## 归档记录

- [x] 记录阶段 1–7 的自动检查链接和现场验收延期。
- [x] 记录未执行第二台设备、boot/switch、EFI 写入和真实会话切换。
- [x] 推送完成后直接归档阶段 8并更新主任务清单。
