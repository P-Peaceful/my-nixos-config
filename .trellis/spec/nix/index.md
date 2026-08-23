# Nix / NixOS 项目规范

本目录约束仓库中的 Nix Flake、NixOS 模块和 Home Manager 模块。阶段 1 只建立输入与目录契约；后续阶段新增实现时，必须先阅读本索引及清单中的指南。

## 适用范围

- `flake.nix`、`flake.lock` 和 Flake 输出
- `hosts/` 下的主机组合
- `modules/nixos/` 下的系统模块
- `modules/home/` 与 `home/` 下的 Home Manager 模块
- Nix 相关 README、架构和运维文档

## 开发前清单

- [ ] 阅读 [`project-guidelines.md`](./project-guidelines.md)，确认目录、所有权、命名、格式、输入和验证约束。
- [ ] 阅读父任务的 [官方模块研究](../../tasks/08-23-nixos-26-05-multi-device/official-research.md)，确认上游接口和版本边界。
- [ ] 在修改输入、模块选项或版本前，先搜索仓库中的所有引用，并以锁定输入中的实际接口为准。
- [ ] 若新增主机，先取得真实的 `hardware-configuration.nix`；不得创建硬件占位文件。
- [ ] 编写或修改 Flake 后运行格式检查、`nix flake metadata` 和 `nix flake check`；没有 Nix 时必须明确记录“待目标 NixOS 执行”。

## 质量检查

- Flake 输入数量、跟随关系和输出范围符合项目规范。
- 公共模块不包含主机名、硬件 UUID、用户密码或设备特定路径。
- 系统模块与 Home Manager 模块的配置所有权唯一，不重复启用同一服务。
- 未把后续阶段的主机、模块或设备配置提前放入阶段 1。
- `flake.lock` 与 `flake.nix` 同步；不能手工编造锁定修订。
