---
name: docusaurus-blog-guide
description: >-
  Use this skill whenever the user is working with Docusaurus, especially for
  blog authoring, configuration questions, Markdown/MDX syntax, deployment, or
  when they need to find the right official documentation page. Trigger on
  mentions of Docusaurus, docusaurus.config.js, blog posts, Markdown features,
  admonitions, tabs, code blocks, deployment, i18n, or updating stale
  documentation references. This skill provides a cached reference to the
  official docs so you can answer quickly and point the user to the exact source
  URL.
---

# Docusaurus Blog Guide

This skill helps users navigate Docusaurus configuration, blog authoring, and
Markdown/MDX features by consulting a local cache of the official documentation.
It is designed for users who write blogs in Chinese but need to know where to
find configuration settings and what Markdown features are available.

## Reference files

Read the relevant reference file whenever the user's question touches one of
these areas:

- **Configuration or deployment questions** → `references/config-pages.md`
- **Markdown/MDX syntax and features** → `references/markdown-features.md`
- **Finding the official URL for a topic** → `references/url-index.md`

If you need a quick map, read `url-index.md` first. It lists every cached page,
its official URL, and which reference file contains the summary.

## When to use this skill

- The user asks where a Docusaurus setting lives (e.g. "博客配置在哪里？", "how
  do I change the navbar?", "where is `routeBasePath` set?").
- The user wants to know what Markdown/MDX syntax Docusaurus supports (e.g.
  "Docusaurus 支持 :::warning 吗？", "how do tabs work?", "can I use Mermaid
  diagrams?").
- The user wants to update the local reference cache because the official docs
  have changed.
- The user is writing a blog post and needs to know frontmatter fields, image
  handling, or truncation syntax.

## How to answer

1. **Identify the area.** Is it config, blog setup, Markdown/MDX, or deployment?
2. **Read the relevant reference.** Use the file names above. Do not rely on
   memory of the official docs if the reference file is available.
3. **Cite the official URL.** Every summary in the reference files includes the
   source URL. Always include that URL in your answer so the user can verify or
   read deeper.
4. **Answer in the user's language.** The user primarily blogs in Chinese, so
   respond in Chinese unless they explicitly switch to English.

## Updating the reference cache

The bundled reference files are a snapshot of the official docs. If the user
says the local docs are outdated or you suspect the official docs have changed,
refresh the cache like this:

1. Read `references/url-index.md` to get the list of official URLs.
2. For each URL that needs updating, use `WebFetch` to fetch the current page.
3. Rewrite the corresponding section in `references/config-pages.md` or
   `references/markdown-features.md` with the new content, keeping the same
   format: URL, Summary, Common syntax, Gotchas.
4. Update `references/url-index.md` if any official URLs changed (e.g. redirects
   or new pages).
5. Tell the user which files you updated and which URLs were refreshed.

Do not invent URLs. If an official page has moved, find the real new URL via
WebFetch or web search before updating the index.

## Common question patterns

**Where is a config setting?**
- Read `references/config-pages.md`.
- Point the user to the exact file: `docusaurus.config.js`, `blog/authors.yml`,
  `blog/tags.yml`, or `themeConfig`.
- Include the official URL for the relevant page.

**What Markdown features can I use?**
- Read `references/markdown-features.md`.
- Quote the exact syntax from the reference.
- Mention any required plugin or config change (e.g. Mermaid theme, math
  plugins).

**How do I write a blog post?**
- Read the **Blog** section in `references/config-pages.md` for frontmatter and
  file structure.
- Read `references/markdown-features.md` for writing syntax.
- Recommend co-locating assets in the same folder as the post.
- Remind the user to use `<!-- truncate -->` for `.md` or `{/* truncate */}`
  for `.mdx`.

**How do I update the docs?**
- Follow the "Updating the reference cache" steps above.

## Examples

**User:** "Docusaurus 博客的 truncate 语法是什么？"
**Response:** Read `references/markdown-features.md` and the **Blog** section of
`references/config-pages.md`, then answer with the exact syntax and the source
URL (https://docusaurus.io/docs/blog).

**User:** "我想加 admonition，支持哪些类型？"
**Response:** Read `references/markdown-features.md` **Admonitions** section and
answer with the built-in types (`note`, `tip`, `info`, `warning`, `danger`),
title syntax, and the source URL
(https://docusaurus.io/docs/markdown-features/admonitions).

**User:** "这个本地文档是不是旧了？"
**Response:** Read `references/url-index.md`, fetch the relevant official URLs,
update the reference files, and report what changed.
