# 阶段 4：Home Manager 与 Fcitx5

## 目标与用户价值

在已完成的 `thinkbook14` 通用笔记本系统角色上接入单用户 Home Manager，并提供可随系统闭包构建的中文输入法用户服务。用户可以获得明确、可验证的用户级配置入口，同时继续保持当前系统无显示管理器、无桌面会话的阶段边界。

## 背景与约束

- 父任务已完成阶段 1 至阶段 3 的仓库基础、`thinkbook14` 核心系统和通用笔记本角色规划。
- Flake 已声明 `home-manager` 的 `release-26.05` 输入，并使其跟随仓库 `nixpkgs`。
- 当前 Flake 输出尚未把 Home Manager NixOS 模块接入 `nixosConfigurations.thinkbook14`，仓库也尚无 `home/` 用户配置入口。
- `wenzhengcheng` 已由 NixOS 核心模块创建；本任务只配置该用户，不创建第二个用户。
- 上游核对已记录在 `research/home-manager-fcitx5-interface.md`：Home Manager Fcitx5 使用 `i18n.inputMethod.enable/type`、`i18n.inputMethod.fcitx5.addons`，并自动提供 Fcitx5 systemd 用户服务。
- 当前工作区没有 `nix`、`nixos-rebuild` 或 `flake.lock`；未运行的 Nix 检查必须记录为“待目标 NixOS 执行”，不能报告为通过。

## 范围内需求

- R1：将 `home-manager.nixosModules.home-manager` 接入 `nixosConfigurations.thinkbook14`，使 Home Manager activation 随系统闭包构建。
- R2：设置 `home-manager.useGlobalPkgs = true` 与 `home-manager.useUserPackages = true`。
- R3：创建公共 Home Manager core 与 `home/wenzhengcheng/default.nix` 用户入口，固定 `home.stateVersion = "26.05"`。
- R4：由 Home Manager 启用 Fcitx5 用户能力，仅加入 `pkgs.fcitx5-rime`，使用其提供的 systemd 用户服务，不新增自定义 unit、会话脚本或系统级重复配置。
- R5：保持配置最小化，不声明自定义 Rime 词库、主题、布局、快捷键、输入法规则或个人应用清单。

## 验收标准

- [ ] AC1（R1）：`flake.nix` 传入 Home Manager 输入并接入 `home-manager.nixosModules.home-manager`；`thinkbook14` 系统闭包包含 Home Manager activation。
- [ ] AC2（R2）：`home-manager.useGlobalPkgs` 和 `home-manager.useUserPackages` 求值为 `true`。
- [ ] AC3（R3）：用户入口存在，`home.stateVersion` 求值为 `26.05`，且目标用户为 `wenzhengcheng`。
- [ ] AC4（R4）：Home Manager 配置启用 Fcitx5、包含 `fcitx5-rime`，并生成其 Fcitx5 systemd 用户服务；不存在 NixOS 层重复的 Fcitx5 所有者。
- [ ] AC5（R5）：配置中没有自定义词库、主题、布局、快捷键、GDM、GNOME、Niri、Noctalia 或其他桌面能力。
- [ ] AC6：在具备 Nix 的目标环境运行 `nix fmt -- --check .`、`nix flake check`、thinkbook14 系统闭包构建和关键选项求值；当前环境统一记录为“待目标 NixOS 执行”。
- [ ] AC7：用户在目标环境验证 Home Manager activation、中文输入法和用户服务启动；本任务不执行 `nixos-rebuild switch` 或 `boot`。

## 范围外

- GDM、GNOME、Niri、Noctalia 或其他图形桌面能力。
- 自定义 Rime 词库、主题、布局、快捷键、输入法规则或个人应用清单。
- 第二个用户、硬件配置、磁盘/EFI 设置、主机专属硬件事实或系统级输入法重复配置。
- `flake.lock` 生成、现场部署、`nixos-rebuild boot`、`switch` 或破坏性修改。

## 风险、延后项与回滚

- Home Manager/Fcitx5 选项必须在目标环境的实际锁定输入上再次求值；若接口与上游分支不一致，暂停实现并修订设计，不凭旧版本接口继续。
- 目标环境的 Fcitx5 用户服务、中文输入和 activation 属于手动验收项；自动检查只能证明配置可求值和系统闭包可构建。
- 若 activation 或输入法配置导致系统不可用，从阶段 3 的已验证系统代回滚；本任务不触碰 EFI 或现场系统切换。
