#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
CLAUDE_MD="$SCRIPT_DIR/CLAUDE.md"

# Non-interactive options
INSTALL_GLOBAL=false
INSTALL_SKILLS=false
INSTALL_CLAUDE_MD=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global) INSTALL_GLOBAL=true; shift ;;
    --skills) INSTALL_SKILLS=true; shift ;;
    --claude-md) INSTALL_CLAUDE_MD=true; shift ;;
    --all) INSTALL_SKILLS=true; INSTALL_CLAUDE_MD=true; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

echo "选择要安装的内容："
echo "  1) skills（本地 skill 插件）"
echo "  2) Karpathy CLAUDE.md（编码风格）"
echo "  3) 全部"
read -rp "请选择 [1/2/3]: " what

install_skills() {
  local target_dir="$1"
  mkdir -p "$target_dir"

  if [ -z "$(ls -A "$SKILLS_DIR" 2>/dev/null)" ]; then
    echo "skills 目录为空，跳过" >&2
    return
  fi

  for skill in "$SKILLS_DIR"/*/; do
    name=$(basename "$skill")
    target="$target_dir/$name"

    if [ -L "$target" ]; then
      rm "$target"
    elif [ -e "$target" ]; then
      echo "skip $name (非符号链接，已存在)" >&2
      continue
    fi

    ln -s "$skill" "$target"
    echo "linked $name"
  done
  echo "skills 已安装到 $target_dir"
}

install_claude_md() {
  local target_dir="$1"
  local target_file="$target_dir/CLAUDE.md"

  if [ ! -f "$CLAUDE_MD" ]; then
    echo "CLAUDE.md 不存在，跳过" >&2
    return
  fi

  if [ -L "$target_file" ]; then
    rm "$target_file"
  elif [ -e "$target_file" ]; then
    echo "skip CLAUDE.md (已存在)" >&2
    return
  fi

  ln -s "$CLAUDE_MD" "$target_file"
  echo "linked CLAUDE.md -> $target_file"
}

# Non-interactive global install
if $INSTALL_GLOBAL; then
  if $INSTALL_SKILLS; then
    install_skills "$HOME/.claude/skills"
  fi
  if $INSTALL_CLAUDE_MD; then
    install_claude_md "$HOME/.claude"
  fi
  exit 0
fi

echo ""
echo "安装到："
echo "  1) 全局（~/.claude/）"
echo "  2) 项目目录（指定路径）"
read -rp "请选择 [1/2]: " where

case "$where" in
  1)
    case "$what" in
      1|3) install_skills "$HOME/.claude/skills" ;;
    esac
    case "$what" in
      2|3) install_claude_md "$HOME/.claude" ;;
    esac
    ;;
  2)
    read -rp "请输入项目路径: " project_path
    if [ ! -d "$project_path" ]; then
      echo "错误: $project_path 不存在" >&2
      exit 1
    fi
    case "$what" in
      1|3) install_skills "$project_path/.claude/skills" ;;
    esac
    case "$what" in
      2|3) install_claude_md "$project_path" ;;
    esac
    ;;
  *)
    echo "无效选择" >&2
    exit 1
    ;;
esac

echo "完成"
