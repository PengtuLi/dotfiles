# Docusaurus Configuration Pages Reference

Quick reference to the most important Docusaurus configuration pages. Each section includes the official URL, key points, and commonly needed syntax.

---

## Configuration

- **URL:** https://docusaurus.io/docs/configuration
- **Summary:**
  - `docusaurus.config.js` runs in Node.js and must export a config object or an async function returning one.
  - Supports ES Modules, CommonJS, and TypeScript.
  - Common top-level sections: site metadata (`title`, `url`, `baseUrl`, `favicon`), deployment fields, themes/plugins/presets, and `customFields` for arbitrary values.
  - Access the config in React components with `useDocusaurusContext()`.
  - Customize Babel via `babel.config.js` using `@docusaurus/babel/preset`; restart the dev server after changes.
- **Common syntax:**
  ```js
  export default {
    title: 'My Site',
    url: 'https://example.com',
    baseUrl: '/',
    favicon: 'img/favicon.ico',
    customFields: {
      myEnv: process.env.MY_VAR,
    },
  };
  ```
  ```js
  import { useDocusaurusContext } from '@docusaurus/core/common';
  const { siteConfig } = useDocusaurusContext();
  ```
- **Gotchas:**
  - Unknown top-level fields are rejected; put custom values under `customFields`.
  - Restart the dev server after Babel changes.

---

## `docusaurus.config.js` API

- **URL:** https://docusaurus.io/docs/api/docusaurus-config
- **Summary:**
  - Required fields: `title`, `url`, `baseUrl`.
  - Optional key fields: `favicon`, `trailingSlash`, `i18n`, `themeConfig`, `plugins`, `themes`, `presets`, `markdown`, `customFields`, `staticDirectories`, `headTags`, `scripts`, `stylesheets`, `clientModules`, `ssrTemplate`, `noIndex`, `onBrokenLinks`, `onBrokenAnchors`, `storage`, `future`.
  - `onBrokenLinks` defaults to `'throw'` and only runs in production builds.
  - `onBrokenMarkdownLinks` is deprecated in v3.9 and removed in v4; use `markdown.hooks.onBrokenMarkdownLinks` instead.
  - `scripts` are render-blocking by default unless you add `async: true` or `defer: true`.
- **Common syntax:**
  ```js
  export default {
    title: 'Docusaurus',
    url: 'https://docusaurus.io',
    baseUrl: '/',
    trailingSlash: false,
    onBrokenLinks: 'throw',
    onBrokenAnchors: 'warn',
    i18n: {
      defaultLocale: 'en',
      locales: ['en', 'fr'],
    },
  };
  ```
  ```js
  export default async function createConfigAsync() {
    return { title: 'Async Config', url: 'https://example.com' };
  }
  ```
- **Gotchas:**
  - Unknown top-level fields cause build errors; use `customFields`.
  - Disable `baseUrlIssueBanner` if you use a strict CSP because it inlines CSS/JS.

---

## Blog

- **URL:** https://docusaurus.io/docs/blog
- **Summary:**
  - Create a `blog/` folder and add Markdown/MDX files; Docusaurus infers metadata.
  - Add a navbar link: `{ to: 'blog', label: 'Blog', position: 'left' }`.
  - Use `<!-- truncate -->` (`.md`) or `{/* truncate */}` (`.mdx`) to define list-page summaries.
  - Global authors live in `blog/authors.yml`; tags can live in `blog/tags.yml`.
  - Supports RSS/Atom/JSON feeds via `feedOptions`, reading time, and multiple blogs via distinct plugin IDs.
- **Common syntax:**
  ```js
  // docusaurus.config.js (preset-classic blog options)
  ['@docusaurus/preset-classic', {
    blog: {
      showReadingTime: true,
      postsPerPage: 'ALL',
      blogSidebarCount: 'ALL',
      feedOptions: { type: ['rss', 'atom'], copyright: '...' },
    },
  }]
  ```
  ```md
  ---
  title: My Post
  authors: jmarcey
  tags: [intro]
  date: 2021-09-13T10:00
  ---
  <!-- truncate -->
  ```
- **Gotchas:**
  - Author pages only work for global authors (`blog/authors.yml`), not inline authors.
  - Feed generation requires an author email for the feed entry.
  - Blog-only mode needs `routeBasePath: '/'`, disabling docs, and removing the `src/pages/index.js` homepage.
  - Multiple blogs need unique `id` and unique `routeBasePath` values.

---

## Deployment

- **URL:** https://docusaurus.io/docs/deployment
- **Summary:**
  - Build with `npm run build`; output is emitted to the `build/` directory.
  - Test locally with `npm run serve`.
  - Set `url`, `baseUrl` (with trailing slash), and `trailingSlash` to match your host's behavior.
  - Docusaurus only produces static files; host them on any static host (GitHub Pages, Netlify, Vercel, Cloudflare Pages, etc.).
  - GitHub Actions examples are provided for `test-deploy.yml` and `deploy.yml`.
- **Common syntax:**
  ```js
  export default {
    url: 'https://your-org.github.io',
    baseUrl: '/my-project/',
    trailingSlash: false,
    organizationName: 'your-org',
    projectName: 'my-project',
    deploymentBranch: 'gh-pages',
  };
  ```
- **Gotchas:**
  - For GitHub Pages, add a `.nojekyll` file to `static/` so Jekyll does not strip files starting with `_`.
  - Netlify's Pretty URLs can cause redirects/404s; disable it and set `trailingSlash` correctly.
  - Pass environment variables to client code via `customFields` because `docusaurus.config.js` is the only Node.js interface.

---

## Internationalization (i18n) Introduction

- **URL:** https://docusaurus.io/docs/i18n/introduction
  - Note: the originally requested URL `https://docusaurus.io/docs/i18n/i18n-introduction` returned 404; the official page is `/docs/i18n/introduction`.
- **Summary:**
  - Workflow: Configure → Translate → Deploy.
  - Translation files live in `website/i18n/[locale]/[pluginName]/...`; for multi-instance plugins use `website/i18n/[locale]/[pluginName]-[pluginId]/...`.
  - Three translation types: Markdown/MDX documents, JSON labels (Chrome i18n format), and plugin data files (e.g. `authors.yml`).
  - Initialize JSON labels with `docusaurus write-translations`.
  - Built-in RTL support, `hreflang` SEO headers, and Crowdin compatibility.
- **Common syntax:**
  ```js
  export default {
    i18n: {
      defaultLocale: 'en',
      locales: ['en', 'fr', 'zh-Hans'],
      localeConfigs: {
        en: { label: 'English', direction: 'ltr' },
      },
    },
  };
  ```
  ```bash
  docusaurus write-translations --locale fr
  ```
- **Gotchas:**
  - Docusaurus does not auto-detect locale or translate URL slugs by design.
  - Locale labels must be configured manually in `localeConfigs`.

---

## Static Site Generation (SSG)

- **URL:** https://docusaurus.io/docs/advanced/ssg
- **Summary:**
  - Docusaurus builds the theme in two passes: SSR (server render to static HTML) and browser hydration.
  - SSR runs in a React DOM Server sandbox with no `window` or `document`.
  - The first client render must match the server-rendered DOM exactly to avoid hydration issues.
  - Use browser-only escape hatches when rendering depends on the browser.
- **Common syntax:**
  ```jsx
  import BrowserOnly from '@docusaurus/BrowserOnly';
  import useIsBrowser from '@docusaurus/useIsBrowser';

  // Browser-only rendering
  <BrowserOnly>{() => <span>Window width: {window.innerWidth}</span>}</BrowserOnly>

  // Browser-only value
  const isBrowser = useIsBrowser();
  ```
  ```jsx
  import ExecutionEnvironment from '@docusaurus/ExecutionEnvironment';
  if (ExecutionEnvironment.canUseDOM) { /* safe action */ }
  ```
- **Gotchas:**
  - Using `window`, `document`, or other browser globals during SSR causes `ReferenceError: window is not defined`.
  - A `typeof window !== 'undefined'` guard can break hydration if the server and client render different markup.
  - `process.env.NODE_ENV` is the one Node global safe to use because Webpack injects it.
  - `useEffect` runs only on the client, so it is safe for browser side effects.

---
