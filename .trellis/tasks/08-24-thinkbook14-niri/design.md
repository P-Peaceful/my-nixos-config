# 阶段 6：Niri 官方默认会话技术设计

## 模块边界

```text
flake.nix
  └─ nixosConfigurations.thinkbook14
       ├─ modules/nixos/core
       ├─ modules/nixos/roles/laptop.nix
       ├─ modules/nixos/desktop/gdm-gnome.nix
       ├─ modules/nixos/desktop/niri.nix
       ├─ hosts/thinkbook14
       └─ Home Manager → 用户级 Fcitx5 + Rime
```

- `modules/nixos/desktop/niri.nix` 是阶段 6 唯一的 Niri 系统配置所有者。
- `hosts/thinkbook14/default.nix` 只负责导入模块，不复制 Niri 或依赖包选项。
- Niri 官方模块负责会话注册、推荐门户和 GNOME Keyring 集成；本阶段不重写这些上游默认行为。
- Home Manager 继续只拥有 Fcitx5 + Rime；阶段 6 不新增用户服务或会话环境覆盖。
- 阶段 5 的 GDM/GNOME 模块保留为独立恢复入口，不能由 Niri 模块替换或设置默认会话。

## 配置合同

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

不声明 `programs.niri.settings`、`config.kdl`、Waybar、Noctalia、主题、布局、快捷键或插件。上游默认 Niri 配置可以引用尚未由本阶段提供的桌面外壳；本阶段只验证 Niri 会话注册和指定最小依赖，不提前接入阶段 7 的 Noctalia。

## 数据流与验证

```text
NixOS 官方 Niri 模块
  → GDM 会话注册 / Wayland 门户 / GNOME Keyring
  → 用户从 GDM 选择 Niri
  → 上游默认 Niri 配置
  → Alacritty / Fuzzel / xwayland-satellite
  → Home Manager Fcitx5 + Rime
```

CI 验证最终合并配置，而不是只搜索模块文本：Niri enable/useNautilus、GDM、GNOME 恢复入口、系统包、门户/Keyring 和主机闭包都要检查。现场登录、快捷键和注销属于延期验收记录。

## 兼容性与回滚

- NixOS 26.05 官方模块负责安装和注册 Niri 会话；不自行写入 GDM desktop 文件。
- `xwayland-satellite` 必须进入系统 `PATH`，以满足 Niri 官方 X11 兼容路径。
- 失败时从 GDM 选择 GNOME，或回退到阶段 5 系统代；本阶段不执行 boot/switch 或 EFI 操作。
