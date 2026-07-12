# Bella's Blog

使用 Astro 构建、通过 GitHub Pages 托管的个人博客。

## 本地预览

```bash
npm install
npm run dev
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

## 首次启用 GitHub Pages

1. 进入仓库的 **Settings → Pages**。
2. 在 **Build and deployment → Source** 中选择 **GitHub Actions**。
3. 推送一次代码，等待 Actions 中的部署任务完成。
4. 访问 <https://bellabiu888.github.io/bella_blogs/>。

站点标题、描述和部署地址在 `astro.config.mjs` 与 `src/layouts/BaseLayout.astro` 中修改。
