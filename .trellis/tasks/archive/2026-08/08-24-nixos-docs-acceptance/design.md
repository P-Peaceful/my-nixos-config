# 阶段 8：文档与多设备扩展验收技术设计

## 文档边界

```text
docs/architecture.md  → 结构、所有权、数据流、新设备流程
docs/operations.md    → 输入、检查、构建、部署、回滚、EFI 与系统代
README.md             → 当前阶段和快速入口
.trellis/tasks/...    → 阶段级可追溯验收记录
```

- 文档只描述已存在的 `thinkbook14` 和可复用模块，不创建第二台设备配置。
- `docs/architecture.md` 解释“代码放在哪里”；`docs/operations.md` 解释“如何安全验证和部署”。
- 阶段清单保留每阶段详细链接和用户要求的自动推进例外；文档不覆盖或伪造现场结果。

## 内容合同

- 架构文档必须列出 `flake.nix`、`hosts/`、`modules/nixos/core`、`modules/nixos/roles`、`modules/nixos/desktop`、`modules/home`、`home/` 的所有权。
- 运维文档必须区分 `nix flake check`、主机闭包构建、`boot`、`switch`、回滚和 EFI 写入的风险边界。
- 新设备流程先收集真实 `hardware-configuration.nix` 和设备事实，再组合公共核心/角色；不得复制 `thinkbook14` 身份。
- Windows EFI 说明只能给出条件分支，不猜测分区 UUID、挂载点或 loader 路径。
