#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

usage() {
  printf '%s\n' \
    "Bella's Blog 常用命令" \
    "" \
    "用法：./run.sh <命令> [参数]" \
    "" \
    "命令：" \
    "  install                  安装或更新依赖" \
    "  dev                      启动本地开发服务器" \
    "  build                    类型检查并生成生产版本" \
    "  preview                  本地预览生产版本" \
    "  new <文件名> [文章标题]   新建 Markdown 文章" \
    "  publish [提交说明]        构建、提交并推送到 GitHub" \
    "  status                   查看 Git 和最近部署状态" \
    "  help                     显示这份帮助" \
    "" \
    "示例：" \
    "  ./run.sh dev" \
    "  ./run.sh new astro-notes 'Astro 学习笔记'" \
    "  ./run.sh publish '新增 Astro 学习笔记'"
}

require_node_modules() {
  if [[ ! -d node_modules ]]; then
    printf '尚未安装依赖，正在运行 npm install...\n'
    npm install
  fi
}

command="${1:-help}"
shift || true

case "$command" in
  install)
    npm install
    ;;
  dev)
    require_node_modules
    npm run dev
    ;;
  build)
    require_node_modules
    npm run build
    ;;
  preview)
    require_node_modules
    npm run build
    npm run preview
    ;;
  new)
    slug="${1:-}"
    title="${2:-}"
    if [[ -z "$slug" ]]; then
      printf '错误：请提供文章文件名。\n例如：./run.sh new astro-notes "Astro 学习笔记"\n' >&2
      exit 1
    fi
    if [[ ! "$slug" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
      printf '错误：文件名只能包含小写字母、数字和连字符。\n' >&2
      exit 1
    fi
    if [[ -z "$title" ]]; then
      title="$slug"
    fi
    file="src/content/blog/${slug}.md"
    if [[ -e "$file" ]]; then
      printf '错误：文章已存在：%s\n' "$file" >&2
      exit 1
    fi
    printf '%s\n' \
      '---' \
      "title: \"$title\"" \
      'description: 请填写一句话简介' \
      "pubDate: $(date +%Y-%m-%d)" \
      'tags: [随笔]' \
      'draft: true' \
      '---' \
      '' \
      '从这里开始写正文。' > "$file"
    printf '已创建：%s\n提示：写完后将 draft 改为 false。\n' "$file"
    ;;
  publish)
    message="${1:-更新博客}"
    require_node_modules
    npm run build
    git add .
    if git diff --cached --quiet; then
      printf '没有需要发布的改动。\n'
      exit 0
    fi
    git commit -m "$message"
    git push origin main
    printf '发布已触发：%s\n' 'https://bellabiu888.github.io/bella_blogs/'
    ;;
  status)
    git status --short --branch
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
      printf '\n最近的 GitHub Actions：\n'
      gh run list --limit 3
    fi
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    printf '未知命令：%s\n\n' "$command" >&2
    usage >&2
    exit 1
    ;;
esac
