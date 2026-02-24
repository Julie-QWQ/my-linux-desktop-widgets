# Conky Multi-Instance Desktop

## 项目简介
这是一个基于 Conky + Lua + Cairo 的多实例桌面组件项目。
每个组件都是独立 Conky 进程，统一由脚本启动与停止。

当前包含 5 个实例：
- `icon`: Ubuntu ASCII Logo
- `datetime`: 时间与日期
- `signature`: 签名打字机效果
- `fetch`: 系统信息（类似 neofetch 右侧信息）
- `music`: CAVA 驱动的音乐频谱柱状图

## 目录结构
- `common/`: 共享 Lua 工具（目前主要是 `shadow.lua`）
- `icon/`: Logo 组件（`conky.conf`, `main.lua`, `ubuntu_logo.lua`）
- `datetime/`: 时间组件（`conky.conf`, `main.lua`, `widget.lua`）
- `signature/`: 签名组件（`conky.conf`, `main.lua`, `widget.lua`）
- `fetch/`: 系统信息组件（`conky.conf`, `main.lua`, `widget.lua`）
- `music/`: 音乐频谱组件（`conky.conf`, `main.lua`, `widget.lua`）
- `scripts/`: 启停脚本（`start-conky.sh`, `stop-conky.sh`）

## 运行方式
启动全部实例：
```bash
bash ~/.config/conky/scripts/start-conky.sh
```

停止全部实例：
```bash
bash ~/.config/conky/scripts/stop-conky.sh
```

单独启动某个组件：
```bash
conky -c ~/.config/conky/icon/conky.conf
conky -c ~/.config/conky/datetime/conky.conf
conky -c ~/.config/conky/signature/conky.conf
conky -c ~/.config/conky/fetch/conky.conf
conky -c ~/.config/conky/music/conky.conf
```

## CAVA 数据流说明
`music` 组件依赖 `~/cava.txt`。

`start-conky.sh` 会自动：
- 启动 `cava`
- 将每帧输出写入 `~/cava.txt`
- 文件始终只保留最新一行（不保留历史）

实现方式为原子替换写入：
- 先写 `~/.cache/cava.latest.tmp`
- 再 `mv` 到 `~/cava.txt`

这样可以减少读取到半行数据导致的闪烁。

## 组件配置入口
每个组件都遵循相同结构：
- `conky.conf`: Conky 实例参数（刷新率、窗口尺寸、位置）
- `main.lua`: 组件入口，负责建立 Cairo context 并调用绘制函数
- `widget.lua` 或 `ubuntu_logo.lua`: 实际绘制逻辑与样式参数

## 常用调参项
- 位置：`X`, `Y`, `BASELINE_Y`, `gap_x`, `gap_y`
- 刷新率：各组件 `conky.conf` 的 `update_interval`
- 样式：字体、字号、颜色、阴影参数
- 音乐柱子：`BAR_WIDTH`, `BAR_GAP`, `MAX_LEVEL`, `PX_PER_LEVEL`, `BAR_COLORS`

## 性能建议
- 降低 `music/conky.conf` 的刷新频率可显著降低 CPU（`update_interval` 变大）
- 减小 `BAR_WIDTH` 可降低绘制开销
- 阴影扩散是高开销项，当前 `music` 采用单层阴影块叠加
- 若出现闪烁，优先检查 `cava` 是否稳定输出，以及 `~/cava.txt` 是否持续更新

## 故障排查
1. 无显示或位置异常：检查对应组件 `conky.conf` 的窗口尺寸与 `alignment/gap_x/gap_y`
2. 音乐不动：检查 `cava` 是否在运行，以及 `~/cava.txt` 是否有最新数据
3. CPU 偏高：优先调 `music` 的 `update_interval` 和柱子尺寸
4. 某个组件不生效：先单独启动该组件，观察 Conky 输出日志

## 兼容说明
项目以多实例为主，不依赖根目录单实例入口。
建议统一使用 `scripts/start-conky.sh` / `scripts/stop-conky.sh` 管理生命周期。

## 开机自启动
推荐使用 `systemd --user`，稳定且便于重启后恢复。

### 方案 A：systemd --user（推荐）
1. 创建用户服务文件：
```bash
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/conky-suite.service <<'UNIT'
[Unit]
Description=Conky Multi-Instance Suite
After=graphical-session.target
Wants=graphical-session.target

[Service]
Type=oneshot
ExecStart=/bin/bash /home/julie/.config/conky/scripts/start-conky.sh
ExecStop=/bin/bash /home/julie/.config/conky/scripts/stop-conky.sh
RemainAfterExit=yes
TimeoutStartSec=20
TimeoutStopSec=20

[Install]
WantedBy=default.target
UNIT
```

2. 启用并立即启动：
```bash
systemctl --user daemon-reload
systemctl --user enable --now conky-suite.service
```

3. 常用管理命令：
```bash
systemctl --user status conky-suite.service
systemctl --user restart conky-suite.service
systemctl --user stop conky-suite.service
```

### 方案 B：桌面“启动应用”
在 GNOME 的“启动应用”里新增一项，命令填：
```bash
/bin/bash /home/julie/.config/conky/scripts/start-conky.sh
```

说明：方案 B 简单，但可观测性和控制能力弱于 `systemd --user`。
