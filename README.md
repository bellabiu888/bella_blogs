# Bella's Blog

使用 Astro 构建、通过 GitHub Pages 托管的个人博客。

## 本地预览

```bash
./run.sh install
./run.sh dev
```

浏览器访问终端显示的地址。生产构建使用 `npm run build`。

## 写新文章

在 `src/content/blog/` 新建 Markdown 文件，例如 `my-new-post.md`：

```md
---
title: 文章标题
description: 一句话简介
pubDate: 2026-07-12
tags: [技术, 随笔]
draft: false
---

这里开始写正文。
```

设置 `draft: true` 可暂时隐藏文章。提交并推送到 `main` 后，GitHub Actions 会自动发布。

也可以用脚本创建和发布文章：

```bash
./run.sh new my-new-post "文章标题"
./run.sh publish "新增文章：文章标题"
```

运行 `./run.sh help` 可以查看全部常用命令。
