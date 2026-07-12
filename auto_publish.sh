#!/usr/bin/env bash

set -euo pipefail

BLOG_DIR="$(cd "$(dirname "$0")" && pwd)"
LABEL="com.bella.blog-auto-publish"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
LOG_DIR="$BLOG_DIR/logs"
LOCK_DIR="${TMPDIR:-/tmp}/${LABEL}.lock"
PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

run_publish() {
  cd "$BLOG_DIR"

  if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    log '已有自动发布任务正在运行，本次跳过。'
    return 0
  fi
  trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

  changes="$(git status --porcelain -- src/content/blog public/images)"
  if [[ -z "$changes" ]]; then
    log '文章和图片没有变化，无需发布。'
    return 0
  fi

  log '检测到内容变化：'
  printf '%s\n' "$changes"

  log '开始执行生产构建检查。'
  if ! npm run build; then
    log '构建失败，本次没有提交或发布。请修正文章格式后重试。'
    return 1
  fi

  git add src/content/blog
  if [[ -d public/images ]]; then
    git add public/images
  fi

  if git diff --cached --quiet; then
    log '没有可提交的内容变化。'
    return 0
  fi

  git commit -m "自动发布博客 $(date '+%Y-%m-%d %H:%M')"
  if git push origin main; then
    log '推送成功，GitHub Pages 已开始更新。'
  else
    log '推送失败。提交已保存在本机，请检查网络或远程仓库状态。'
    return 1
  fi
}

install_job() {
  mkdir -p "$HOME/Library/LaunchAgents" "$LOG_DIR"
  printf '%s\n' \
    '<?xml version="1.0" encoding="UTF-8"?>' \
    '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
    '<plist version="1.0">' \
    '<dict>' \
    '  <key>Label</key>' \
    "  <string>$LABEL</string>" \
    '  <key>ProgramArguments</key>' \
    '  <array>' \
    "    <string>$BLOG_DIR/auto_publish.sh</string>" \
    '  </array>' \
    '  <key>WorkingDirectory</key>' \
    "  <string>$BLOG_DIR</string>" \
    '  <key>StartInterval</key>' \
    '  <integer>3600</integer>' \
    '  <key>RunAtLoad</key>' \
    '  <true/>' \
    '  <key>StandardOutPath</key>' \
    "  <string>$LOG_DIR/auto-publish.log</string>" \
    '  <key>StandardErrorPath</key>' \
    "  <string>$LOG_DIR/auto-publish-error.log</string>" \
    '</dict>' \
    '</plist>' > "$PLIST"

  launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$PLIST"
  log '每小时自动发布已启用。'
  log "运行日志：$LOG_DIR/auto-publish.log"
}

uninstall_job() {
  launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
  rm -f "$PLIST"
  log '每小时自动发布已停用。'
}

case "${1:-run}" in
  run) run_publish ;;
  install) install_job ;;
  uninstall) uninstall_job ;;
  status)
    if launchctl print "gui/$(id -u)/$LABEL" >/dev/null 2>&1; then
      log '自动发布正在运行。'
    else
      log '自动发布未启用。'
      exit 1
    fi
    ;;
  *)
    printf '用法：%s [run|install|uninstall|status]\n' "$0" >&2
    exit 1
    ;;
esac
