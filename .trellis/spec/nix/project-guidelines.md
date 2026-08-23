# Nix 项目约定

## 仓库目录与所有权

阶段 1 新增的 Nix 根文件为 `flake.nix`、`flake.lock` 和阶段 README；既有的 Trellis 配置与项目文件不受此表述影响。后续实现按以下边界扩展：

```text
hosts/<主机名>/
  default.nix
  hardware-configuration.nix
modules/
  nixos/core/       # 所有设备共享的系统约束
  nixos/roles/      # 可复用的设备角色，不引用具体主机或硬件标识
  nixos/desktop/    # 系统级会话、门户和恢复能力
  home/             # 可跨设备复用的用户能力
home/<用户名>/       # 用户组合入口和必要的用户级覆盖
docs/                # 架构、运维和阶段记录
```

各层只拥有自己的配置：`flake.nix` 负责输入、外部模块接线、输出和格式化器；主机目录负责主机身份、硬件文件和角色组合；NixOS 模块负责系统级配置；Home Manager 模块负责用户级配置。不要把主机业务逻辑堆进 Flake，也不要让公共模块读取主机名或硬件 UUID。

不要为只使用一次的表达式提前创建通用 helper；只有出现第二个真实使用者且重复逻辑已经明确时，才提取最小共享抽象。

## 命名与模块边界

- 目录和模块文件使用小写 kebab-case；主机名和用户名保持系统实际值。
- 模块入口使用 `default.nix`，聚合模块显式列出 imports。
- 选项路径使用完整的 NixOS 或 Home Manager 命名空间，不用缩写或自定义同名选项遮蔽上游选项。
- 每项服务只有一个配置所有者。系统范围能力放入 NixOS 模块，用户服务、用户包和用户配置放入 Home Manager 模块。
- 主机特定设置留在 `hosts/<主机名>/`；公共角色不得出现 `thinkbook14`、具体分区 UUID、绝对设备路径或个人凭据。
- 未经阶段任务批准，不创建 `nixosConfigurations`、主机模块、Home Manager 配置或设备设置。

## Flake 输入与锁定

当前批准的输入只有：

```nix
nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
home-manager.url = "github:nix-community/home-manager/release-26.05";
noctalia.url = "github:noctalia-dev/noctalia";
```

Home Manager 和 Noctalia 必须使用 `inputs.nixpkgs.follows = "nixpkgs"`，避免同一系统闭包引入第二份 Nixpkgs。不要为简单的单系统 Flake 引入 `flake-utils`、`flake-parts`、`treefmt` 或未获批准的输入。

所有输入必须由 `flake.lock` 固定后才能交付。锁文件只能通过 `nix flake lock` 或等价的 Nix 命令生成，不能凭手工猜测修订、时间戳或哈希。更新输入时单独审阅锁文件变更，并重新运行完整检查。

## 阶段 1 可执行契约

### 1. 范围 / 触发条件

- 触发条件：新增或修改根目录 Flake、输入锁定、Nix 格式化器或 Nix 项目规范。
- 阶段 1 只建立可复现输入基线，不提供可部署的 NixOS 系统闭包。

### 2. 接口与输出签名

- `flake.nix` 输入：`nixpkgs`、`home-manager`、`noctalia` 三项。
- `flake.nix` 输出：仅提供 `formatter.x86_64-linux`。
- 阶段 1 不提供 `nixosConfigurations`、`packages`、`devShells` 或主机输出。

### 3. 输入与锁定契约

- `home-manager.inputs.nixpkgs.follows` 和 `noctalia.inputs.nixpkgs.follows` 必须为 `"nixpkgs"`。
- 交付前必须存在由 `nix flake lock` 生成的 `flake.lock`，并固定三个输入的精确修订。
- 锁文件中的修订、哈希和时间戳必须来自 Nix，不能手工猜测或伪造。

### 4. 验证与错误矩阵

| 条件 | 结果 |
| --- | --- |
| 存在 Nix | 依次运行 `nix flake lock`、`nix fmt -- --check .`、`nix flake metadata`、`nix flake check` |
| 不存在 Nix | 明确记录“待目标 NixOS 执行”，不得声称检查通过 |
| 缺少 `flake.lock` | 阶段验收阻塞，直到目标 NixOS 生成并审阅锁文件 |
| 出现未批准输入或主机输出 | 违反阶段边界，必须删除或退回任务规划 |

### 5. 正确 / 基线 / 错误案例

- 正确：三个批准输入、两个 `follows`、一个 `x86_64-linux` formatter，并由 Nix 生成锁文件。
- 基线：当前环境没有 Nix 时保留未锁定 Flake，同时在 README 和检查结果中标记待目标环境执行。
- 错误：手工编写 `flake.lock`，引入 `flake-utils`，或用空主机配置冒充阶段 1 输出。

### 6. 必需测试与断言点

- `nix flake metadata`：断言三个输入解析成功且分支正确。
- `nix flake check`：断言 Flake 输出可评估且不包含未预期输出。
- `nix fmt -- --check .`：断言 Nix 文件符合仓库 formatter。
- 静态边界检查：断言不存在 `hosts/`、`modules/`、`home/`、`hardware-configuration.nix` 和 `nixosConfigurations`。

### 7. 错误写法与正确写法

错误：

```nix
home-manager.url = "github:nix-community/home-manager/release-26.05";
```

正确：

```nix
home-manager = {
  url = "github:nix-community/home-manager/release-26.05";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

前者可能让同一系统闭包引入第二份 Nixpkgs；后者明确复用仓库的 Nixpkgs 输入。

## 格式与注释

- 使用仓库 Flake 暴露的 `formatter.x86_64-linux`，通过 `nix fmt` 格式化 Nix 文件。
- 保持属性集合和 imports 简洁、稳定排序；不要为一行表达式增加无必要的抽象层。
- 注释和项目文档使用中文；注释解释边界、原因或上游约束，不复述显而易见的语法。
- 代码中的字符串、选项名和上游 API 保持官方拼写；不要把版本号写成模糊的 `latest`。

## 验证契约

修改 Flake 或输入后，在具备 Nix 的环境中按顺序运行：

```sh
nix fmt -- --check .
nix flake metadata
nix flake check
```

当仓库存在主机输出后，再按任务要求增加 `nix build` 和 `nix eval`；阶段 1 不伪造主机输出，也不以空的主机配置替代真实硬件文件。无 Nix 环境时，验证结果必须写为“待目标 NixOS 执行”，不得声称通过。

## 禁止模式

- 在阶段 1 创建 `nixosConfigurations`、`hosts/`、`modules/`、`home/` 或 `hardware-configuration.nix`。
- 混用 Noctalia v4 的 `noctalia-shell` 包、模块或配置路径与 Noctalia v5。
- 让 Home Manager 或 Noctalia 使用未跟随仓库的 Nixpkgs。
- 在公共模块写入机器 UUID、磁盘路径、密码、主机名或个人应用清单。
- 通过复制相似模块、重复服务开关或多份输入定义绕过所有权边界。
- 在无法访问 Nix 时手工生成 `flake.lock`，或把未运行的格式和 Flake 检查报告为通过。

## 官方研究依据

版本和模块边界以父任务的 [官方模块研究](../../tasks/08-23-nixos-26-05-multi-device/official-research.md) 为设计基线，最终选项定义必须以 `flake.lock` 锁定的 Nixpkgs、Home Manager 和 Noctalia 源码为准。该研究中的官方来源包括 NixOS 手册、Nixpkgs 26.05 模块、Home Manager 26.05 文档以及 Noctalia v5 文档和上游 Flake。
