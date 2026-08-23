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

## 阶段化通用闭包例外

### 1. 范围 / 触发条件

仅当当前 Trellis 子任务的 `prd.md` 明确批准“先建立通用系统闭包”，且明确写出不需要 `flake.lock` 和 `hardware-configuration.nix` 时，才允许本例外。该例外只适用于求值、构建和静态检查，不自动扩展为可部署主机。

### 2. 输出签名

- Flake 可以提供 `nixosConfigurations.<主机名>`。
- 主机入口可以只导入公共核心模块，不导入 `hardware-configuration.nix`。
- `boot.loader.systemd-boot.*` 可以作为配置契约声明，但不得据此执行 EFI 写入或现场部署。

### 3. 合同

- 任务必须明确记录未生成 `flake.lock`，并接受输入未锁定的可复现性取舍。
- 任务不得创建空的硬件配置来模拟真实设备事实。
- 没有硬件配置时，不得声明文件系统、UUID、EFI 分区或 Windows loader 路径。
- 未运行的 Nix 检查必须标记为“待目标 NixOS 执行”。

### 4. 验证与错误矩阵

| 条件 | 结果 |
| --- | --- |
| 子任务 PRD 明确批准例外 | 可创建通用主机输出并进行求值/构建规划 |
| PRD 未明确批准例外 | 仍要求 `flake.lock` 和真实硬件配置 |
| 试图用占位硬件文件补齐配置 | 失败，删除占位文件并退回规划 |
| 试图执行 `boot`、`switch` 或 EFI 写入 | 失败，停止部署并要求硬件事实与现场验收 |
| 当前环境没有 Nix | 检查记录为待目标 NixOS 执行，不得报告通过 |

### 5. 正确 / 基线 / 错误案例

- 正确：PRD 明确例外，主机入口只组合核心模块，声明 systemd-boot，且不写入硬件事实。
- 基线：无 `flake.lock` 时保留未锁定输入，并在任务和 README 中记录风险。
- 错误：生成虚假的 `hardware-configuration.nix`、猜测 UUID，或在无现场信息时执行引导部署。

### 6. 必需测试与断言点

- Flake 输出存在 `nixosConfigurations.<主机名>`。
- 主机名、`system.stateVersion`、核心服务和引导选项可静态断言。
- 静态检查确认不存在 `hardware-configuration.nix`、EFI 路径和越界桌面/阶段服务。
- 具备 Nix 时运行 `nix fmt -- --check .`、`nix flake check`、目标闭包构建和关键选项求值。

### 7. 错误写法与正确写法

错误：

```nix
modules = [ ./hardware-configuration.nix ./hosts/thinkbook14 ];
```

正确：

```nix
modules = [ ./modules/nixos/core ./hosts/thinkbook14 ];
```

前者把不存在或未经确认的机器事实伪装成构建依赖；后者只构建已获批准的通用核心闭包，硬件集成由后续任务负责。

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

## 通用笔记本角色契约

### 1. 范围 / 触发条件

- 触发条件：主机需要与桌面无关的通用笔记本系统服务时，使用 `modules/nixos/roles/laptop.nix`。
- 角色只负责系统级服务；主机入口负责导入角色，不复制其中的服务选项。
- 角色不得读取主机名、硬件 UUID、设备路径或用户级配置。

### 2. 签名

角色的 NixOS 模块签名为 `{ ... }: { ... }`，服务合同包含：

```nix
networking.networkmanager.enable
services.pipewire.enable
services.pipewire.pulse.enable
hardware.bluetooth.enable
services.upower.enable
services.power-profiles-daemon.enable
security.polkit.enable
services.fwupd.enable
```

### 3. 合同

- 上述通用服务必须启用。
- `services.fprintd.enable`、`services.printing.enable` 和 `services.hardware.bolt.enable` 必须显式保持关闭。
- 角色不得加入 GDM、桌面会话、Home Manager、输入法、硬件事实或现场部署行为。

### 4. 验证与错误矩阵

| 条件 | 结果 |
| --- | --- |
| 具备目标 Nix 环境 | 运行格式检查、`nix flake check`、目标闭包构建和关键选项求值 |
| 当前环境没有 Nix | 所有 Nix 命令记录为“待目标 NixOS 执行”，不得报告为通过 |
| 角色出现主机或硬件事实 | 违反模块边界，退回并移除该配置 |
| 排除服务被启用或未显式关闭 | 验收失败，修正角色合同后再检查 |

### 5. 正确 / 基线 / 错误案例

- 正确：主机入口仅导入 `../../modules/nixos/roles/laptop.nix`，服务开关集中在角色中。
- 基线：没有 Nix 时完成静态边界检查，并保留待目标环境执行的验证记录。
- 错误：在角色中写入 `thinkbook14`、磁盘 UUID、EFI 路径、桌面模块或用户服务。

### 6. 必需测试

- 静态检查断言角色不包含主机名、硬件事实、桌面、Home Manager 或输入法引用。
- `nix flake check` 与目标闭包构建断言主机输出可求值。
- `nix eval` 分别断言八项通用服务为 `true`，并断言 fprintd、printing 和 Bolt 为 `false`。

### 7. 错误写法与正确写法

错误：

```nix
networking.networkmanager.enable = true;
services.pipewire.enable = true;
```

将服务开关复制到每个主机入口会产生多个配置所有者，后续主机容易出现漂移。

正确：

```nix
imports = [ ../../modules/nixos/roles/laptop.nix ];
```

把通用服务集中到角色模块，并让主机只组合角色，能够保持边界和验收点稳定。

## 禁止模式

- 在阶段 1 创建 `nixosConfigurations`、`hosts/`、`modules/`、`home/` 或 `hardware-configuration.nix`。
- 混用 Noctalia v4 的 `noctalia-shell` 包、模块或配置路径与 Noctalia v5。
- 让 Home Manager 或 Noctalia 使用未跟随仓库的 Nixpkgs。
- 在公共模块写入机器 UUID、磁盘路径、密码、主机名或个人应用清单。
- 通过复制相似模块、重复服务开关或多份输入定义绕过所有权边界。
- 在无法访问 Nix 时手工生成 `flake.lock`，或把未运行的格式和 Flake 检查报告为通过。

## 官方研究依据

版本和模块边界以父任务的 [官方模块研究](../../tasks/08-23-nixos-26-05-multi-device/official-research.md) 为设计基线，最终选项定义必须以 `flake.lock` 锁定的 Nixpkgs、Home Manager 和 Noctalia 源码为准。该研究中的官方来源包括 NixOS 手册、Nixpkgs 26.05 模块、Home Manager 26.05 文档以及 Noctalia v5 文档和上游 Flake。

## Home Manager 与 Fcitx5 用户模块契约

### 1. 范围 / 触发条件

- 触发条件：NixOS Flake 将 Home Manager 作为 NixOS 模块接入，并由 Home Manager 管理用户级输入法。
- 适用目录：`flake.nix`、`home/core/`、`home/<用户名>/`。
- 本契约不授权加入桌面会话、显示管理器或系统级重复输入法配置。

### 2. 接口签名

Flake 组合必须提供以下接口：

```nix
outputs = { nixpkgs, home-manager, ... }: {
  nixosConfigurations.<主机名> = nixpkgs.lib.nixosSystem {
    modules = [
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.<用户名> = import ./home/<用户名>;
      }
    ];
  };
};
```

用户模块的 Fcitx5 接口为：

```nix
i18n.inputMethod = {
  enable = true;
  type = "fcitx5";
  fcitx5.addons = [ pkgs.fcitx5-rime ];
};
```

### 3. 配置合同

- Home Manager 与根 Flake 使用同一 `nixpkgs`，其输入必须声明 `inputs.nixpkgs.follows = "nixpkgs"`。
- 每个用户入口固定自己的 `home.stateVersion`，不得随输入更新自动漂移。
- Home Manager 是用户包、用户配置和 Fcitx5 用户服务的唯一配置所有者。
- Fcitx5 使用 Home Manager 自动生成的 `systemd.user.services.fcitx5-daemon`；除非有独立批准，不自定义同名 unit、会话脚本或环境覆盖。
- 最小 Fcitx5 配置只声明 `enable`、`type` 和批准的附加组件；`settings`、`themes`、`quickPhrase`、`quickPhraseFiles` 等自定义项保持未声明。

### 4. 验证与错误矩阵

| 条件 | 结果 |
| --- | --- |
| `home-manager.nixosModules.home-manager` 未接入 | 失败：用户配置不会随 NixOS 系统闭包构建 |
| `useGlobalPkgs` 或 `useUserPackages` 不是 `true` | 失败：违反单一 Nixpkgs 和用户包路径合同 |
| Fcitx5 使用弃用的 `i18n.inputMethod.enabled` | 失败：改用 `enable = true` 与 `type = "fcitx5"` |
| Fcitx5 addon 不在 Home Manager 用户模块中 | 失败：不得把用户级输入法复制到 NixOS 模块 |
| 当前环境无 Nix | 只能做静态边界检查；格式、求值和构建记录为待目标 NixOS 执行 |

### 5. 正确 / 基线 / 错误案例

- 正确：Flake 接入 Home Manager NixOS 模块，用户入口只声明 `home.stateVersion` 与最小 Fcitx5 合同。
- 基线：没有 `flake.lock` 时不手工伪造锁定值，并在任务与 README 中记录待目标环境验证。
- 错误：在 `modules/nixos/` 再声明一份 Fcitx5 daemon，或在用户入口加入自定义词库、主题、布局和快捷键。

### 6. 必需测试与断言点

- `nix fmt -- --check .`：断言 Flake 与 Home Manager 文件符合仓库格式化器。
- `nix flake check`：断言 Home Manager 模块可合并且 Flake 输出可评估。
- `nix build .#nixosConfigurations.<主机名>.config.system.build.toplevel`：断言 Home Manager activation 进入系统闭包。
- `nix eval`：断言 `home-manager.useGlobalPkgs`、`home-manager.useUserPackages` 为 `true`，用户 `home.stateVersion` 为批准版本。
- 静态检查：断言只存在一个 Fcitx5 配置所有者，且不存在桌面、自定义词库/主题/布局/快捷键或自定义同名 systemd unit。

### 7. 错误写法与正确写法

错误：

```nix
home-manager.users.<用户名> = {
  home.stateVersion = "latest";
  i18n.inputMethod.enabled = "fcitx5";
};
```

正确：

```nix
home-manager.users.<用户名> = import ./home/<用户名>;

# home/<用户名>/default.nix
{
  home.stateVersion = "26.05";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-rime ];
  };
}
```

## GDM 与精简 GNOME 恢复会话契约

### 1. 范围 / 触发条件

- 触发条件：阶段任务需要在 Niri/Noctalia 之前提供独立的图形恢复入口。
- 适用目录：`modules/nixos/desktop/gdm-gnome.nix` 与 `hosts/<主机名>/default.nix`。
- 本契约不授权加入 Niri、Noctalia、Waybar、桌面主题或个人应用配置。

### 2. 配置签名

恢复模块必须显式声明以下最终配置：

```nix
services.displayManager.gdm.enable = true;
services.displayManager.autoLogin.enable = false;
services.desktopManager.gnome.enable = true;
services.gnome.core-apps.enable = false;
i18n.inputMethod.enable = false;
environment.systemPackages = [ pkgs.nautilus ];
```

GNOME 的 Shell、控制中心和门户由官方 GNOME 桌面模块提供；关闭 `core-apps` 后必须显式补回恢复所需的 Nautilus。Bolt 和打印由通用笔记本角色统一声明为关闭，桌面模块不得重复声明。Fcitx5 仍由 Home Manager 用户模块独占，NixOS 层不得再创建输入法用户服务。

### 3. 验证与错误矩阵

| 条件 | 结果 |
| --- | --- |
| GDM、GNOME 或恢复包缺失 | 阶段验收失败，不能归档或进入 Niri 阶段 |
| 自动登录不是 `false` | 阶段验收失败，必须删除自动登录用户和开关 |
| GNOME 默认 IBus、Bolt 或打印被保留 | 阶段验收失败；IBus 在桌面模块关闭，Bolt/打印由笔记本角色保持 `false` |
| 本地没有 Nix | 不得声称本地检查通过；由 CI 执行 Flake 检查和主机闭包构建 |
| CI Flake 检查或闭包构建失败 | 保持任务 `in_progress`，修复后重新检查 |

### 4. CI 自动检查合同

GitHub Actions 至少应在目标分支上执行：

```sh
nix flake check --no-build --show-trace
nix eval --json .#nixosConfigurations --apply builtins.attrNames
nix build .#nixosConfigurations.<主机名>.config.system.build.toplevel --no-link --show-trace
```

CI 只能证明配置求值和系统闭包构建；GDM 密码登录、GNOME/Fcitx5 实际会话、注销和系统代回滚仍属于真实设备手动验收，不能由绿色 CI 自动推断。

### 5. 正确 / 基线 / 错误案例

- 正确：桌面模块集中声明 GDM/GNOME 和 IBus 覆盖，主机入口只导入模块，CI 构建 `nixosConfigurations` 中的每个主机。
- 基线：本地没有 Nix 时保留待 CI 执行的记录，推送后以对应提交的 Action 结果作为自动检查证据。
- 错误：关闭 `core-apps` 后不补 Nautilus，在桌面模块重复声明 Bolt/打印，或为了让 GNOME 输入法工作在 NixOS 层复制一份 Fcitx5/IBus 服务。

### 6. 必需测试与断言点

- 静态检查：桌面模块不包含 Niri、Noctalia、Waybar、主题、插件或硬件事实。
- `nix flake check --no-build --show-trace`：断言 Flake 输出可求值。
- 动态主机矩阵构建：断言每个 `nixosConfigurations.<主机名>.config.system.build.toplevel` 可构建。
- `nix eval`：断言 GDM、GNOME、Nautilus、自动登录、IBus、Bolt、打印和指纹服务的最终值符合阶段合同。
- 手动验收：断言真实设备可以登录 GNOME、使用 Fcitx5 + Rime、打开 Nautilus、注销回 GDM 并启动上一已验证系统代。

## Niri 官方默认会话契约

### 1. 范围 / 触发条件

- 触发条件：阶段 5 GDM/GNOME 恢复入口已提交后，需要接入 NixOS 26.05 官方 Niri 会话。
- 适用目录：`modules/nixos/desktop/niri.nix` 与 `hosts/<主机名>/default.nix`。
- 本契约不授权 Noctalia、Waybar、Niri KDL、自定义 settings、主题、布局、快捷键或插件。

### 2. 配置签名

```nix
programs.niri = {
  enable = true;
  useNautilus = true;
};

environment.systemPackages = with pkgs; [
  alacritty
  fuzzel
  xwayland-satellite
];
```

官方 Niri 模块拥有会话注册、门户和 GNOME Keyring 集成；GDM 仍是唯一显示管理器，不设置 `services.displayManager.defaultSession`。Niri 模块不得复制 GDM/GNOME、Home Manager Fcitx5 或笔记本服务所有权。

### 3. 合同

- `programs.niri.enable` 和 `programs.niri.useNautilus` 必须在最终主机配置中为 `true`。
- Alacritty、Fuzzel 和 `xwayland-satellite` 必须进入系统包闭包；Waybar 不得由阶段 6 安装。
- 阶段 5 的 GDM、GNOME、Nautilus、Fcitx5、Bolt/打印/指纹合同保持不变。
- 用户可从 GDM 选择 Niri 或 GNOME；不得通过默认会话选项隐藏恢复入口。

### 4. 验证与错误矩阵

| 条件 | 结果 |
| --- | --- |
| `programs.niri.enable` 未启用 | 阶段失败，不能归档 |
| 自定义 `config.kdl`、settings 或 Waybar 出现 | 违反官方默认会话边界，删除后重检 |
| Niri 依赖包未进入系统闭包 | 阶段失败，补齐 Alacritty/Fuzzel/xwayland-satellite |
| Niri 覆盖 GDM/GNOME 或 Fcitx5 所有权 | 阶段失败，恢复单一配置所有者 |
| 本地没有 Nix | 由 GitHub Actions 执行 Flake 检查和主机闭包构建，不能声称本地通过 |

### 5. 正确 / 基线 / 错误案例

- 正确：独立 Niri 模块启用官方选项并加入三个运行时包，主机入口只导入模块。
- 基线：不写 Niri 配置文件，让官方模块和二进制默认配置生效，Noctalia 延后到下一阶段。
- 错误：为状态栏提前安装 Waybar、在 Niri 模块复制 Fcitx5 服务，或设置 GDM 默认会话取代 GNOME 回退入口。

### 6. 必需测试与断言点

- 静态检查：断言没有 `config.kdl`、`programs.niri.settings`、Waybar、Noctalia、主题、布局、快捷键和插件。
- `nix eval`：断言 Niri、useNautilus、GDM、GNOME 和相关系统服务最终值。
- 系统包求值：断言 Alacritty、Fuzzel、xwayland-satellite 和 Nautilus 存在，Waybar 不存在。
- `nix flake check`、动态主机闭包构建：断言官方会话模块可合并并完成系统闭包求值。
- 现场会话登录、快捷键、输入法和注销属于独立手动记录；用户明确延期时不得把延期写成通过。

### 7. 错误写法与正确写法

错误：

```nix
programs.niri.settings = {
  spawn-at-startup = [ "waybar" ];
};
```

正确：

```nix
programs.niri = {
  enable = true;
  useNautilus = true;
};
```

前者把桌面外壳和自定义行为提前绑定到阶段 6；后者保留官方默认会话边界，把 Noctalia 和外壳策略留给阶段 7。
