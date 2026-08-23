# NixOS 配置仓库

当前仓库处于阶段 1：仓库与 Nix 规范基础。此阶段只建立可复现输入的 Flake 骨架和项目约定，不提供可部署的 NixOS 系统。

## 当前阶段边界

- `flake.nix` 只声明 Nixpkgs 26.05、Home Manager `release-26.05`、Noctalia 官方 Flake 以及 `x86_64-linux` 格式化器。
- Home Manager 和 Noctalia 的 Nixpkgs 输入跟随仓库的 `nixpkgs` 输入。
- 当前没有 `nixosConfigurations`，也没有 `hosts/`、`modules/`、`home/` 或设备配置。
- 不在此阶段加入用户、引导、桌面、输入法、服务、主题、插件或硬件设置。

## 输入与锁定

输入源和版本策略记录在 [`flake.nix`](./flake.nix) 与项目规范中；所有输入在提交前必须由 `flake.lock` 固定。当前执行环境没有 Nix，无法真实运行 `nix flake lock` 生成 `flake.lock`，因此本阶段的 `flake.lock` 状态为“待目标 NixOS 执行”：文件尚未生成，且没有手工伪造锁文件。

在具备 Nix 的目标环境中，先执行：

```sh
nix flake lock
```

然后提交生成的 `flake.lock`，并重新执行以下检查。

## 检查命令

```sh
nix flake metadata
nix flake check
nix fmt -- --check .
```

本工作区无法执行上述命令，因为没有安装 Nix；以下三项均为“待目标 NixOS 执行”，不能标记为已通过：

- `nix flake metadata`
- `nix flake check`
- `nix fmt -- --check .`

## 阶段 2 前置条件

阶段 2 开始前必须先在目标 NixOS 环境生成并审阅 `flake.lock`，确认三个输入的精确修订，然后由用户提供真实硬件生成的：

```text
hosts/thinkbook14/hardware-configuration.nix
```

该文件必须来自目标设备的硬件探测，不能用占位内容或猜测的 UUID、分区和文件系统。阶段 2 才会创建主机入口和系统模块；本阶段不提前创建这些目录或配置。
