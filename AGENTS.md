# AGENTS.md

This file provides guidance to agentic coding tools (Claude Code, etc.) when working in this repository.

## What this repo is

Orion Li 的个人 dotfiles 仓库，覆盖 macOS、Linux (GUI/headless/WSL) 和 Windows。入口是 `justfile`（先装好 `just`），主要机制：

- **GNU stow** 管理配置：`stow/cli/`（命令行工具）和 `stow/gui/`（桌面应用）下每个子目录是一个 stow 包，包内路径即 `$HOME` 下的目标路径。特例在 `scripts/lib/stow-helpers.sh`：`vscode` 在 macOS 下 stow 到 `~/Library/Application Support`，`smb` stow 到 `/etc`。
- **Shell 配置不走 stow**：`scripts/core/shell-scripts.sh` 往 `~/.zshrc` 追加一行 `source "$ROOT_DIR/shell/zsh/.zshrc"`，并把 `.local/bin/` 下的脚本链接到 `~/.local/bin`。shell 脚本本体在 `shell/`（`zsh/`、`common/`、`bash/`）。
- **Brew 包分组**：`brewfile/Brewfile.{basic,doc,font,osx,remote}`，按平台组合。
- **代理/VPN**：`mihomo-clash/`（Clash Meta 二进制 + 配置，配置目录被 gitignore）、`easytier/`（mesh VPN）。

## 常用命令

```bash
just                # 列出所有预设和组件
just osx            # macOS 完整安装（前置依赖 → stow → shell → extras → brew → vscode）
just linux-headless # Linux 无头/WSL 完整安装
just stow-osx       # 只重新链接 dotfiles（改动 stow/ 后常用）
just ssh-proxy <host>  # 推送 mihomo 代理到远程服务器（自动探测架构）
```

所有预设都是 `scripts/` 下脚本的组合：`scripts/core/`（安装流程）、`scripts/lib/`（公共函数，脚本用 `source scripts/lib/common.sh` 获取 `info`/`error`/`success` 等）、`scripts/extras/`、`scripts/ssh/`（Python，同步 SSH 配置到远程主机，用 `uv pip install -r requirements.txt` 装依赖后跑）。

## 提交与质量

- **Conventional commits**（angular 风格），husky `commit-msg` 钩子跑 commitlint 强制检查。
- `pre-commit run` 在提交前执行：通用检查（trailing-whitespace、yaml/json/toml、大文件、私钥检测）、`ruff-format`（Python）、`gitleaks`（密钥扫描，配置在 `.gitleaks.toml`）。本地手动跑：`pre-commit run --all-files`。
- 仓库没有测试套件；验证改动的方式是跑对应的 `just` 组件命令（如 `just stow-osx`）。

## Secrets 管理（重要）

敏感文件（SSH 私钥、gh token、claude-code settings、easytier 配置、`shell/.env.secrets` 等）**不以明文入库**，而是用 SOPS + age 加密成 `*.sops` 文件提交：

- 加密规则在 `.sops.yaml`（按路径正则匹配）。
- husky `pre-commit` 钩子自动跑 `scripts/crypt/encrypt-secret.sh`：对比明文文件的 checksum，变了才重新加密并 `git add` 对应的 `.sops` 和 `.checksum` 文件。
- husky `post-checkout` 钩子（切分支时）自动跑 `scripts/crypt/decrypt-secret.sh` 还原明文。
- 新增明文 secret 文件时，**不要手动提交明文**——把它加进 `encrypt-secret.sh` 的列表和 `.sops.yaml` 的 creation_rules。没有 age 私钥的机器上解密步骤会跳过/失败，属正常。

## 其他目录

- `vibe/` — AI coding 相关：skills 集合（`vibe/skills/` 下的 skill 通过符号链接装到 `~/.claude/skills/`，见 `link-skills.sh`）。
- `static/` — 壁纸、头像等静态资源。
- `code-snip/` — 代码片段。

## Agent skills

### Issue tracker

Issues are tracked in GitHub Issues for this repo (`PengtuLi/dotfiles`), managed via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Uses the default five-role vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
