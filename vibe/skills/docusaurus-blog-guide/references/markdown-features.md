# Docusaurus Markdown/MDX Features Reference

Quick reference to Markdown and MDX features in Docusaurus. Each section includes the official URL, key points, and commonly needed syntax.

---

## Markdown Features

- **URL:** https://docusaurus.io/docs/markdown-features
- **Summary:**
  - Docusaurus compiles Markdown/MDX files to React components via the MDX compiler.
  - In v3, MDX is the default format even for `.md` files; use `siteConfig.markdown.format` or `mdx.format` front matter to switch.
  - `siteConfig.markdown.format: 'detect'` uses CommonMark for `.md` and MDX for `.mdx` automatically.
  - Standard Markdown works: headings, bold/italic, links, images, quotes, and `<details>`/`<summary>` collapsibles.
  - Front matter is YAML at the top of the file.
- **Common syntax:**
  ```yaml
  ---
  title: My Doc Title
  ---
  ```
  ```js
  // docusaurus.config.js
  export default {
    markdown: {
      format: 'detect', // 'md' | 'mdx' | 'detect'
      mdx1Compat: { headingIds: true },
    },
  };
  ```
  ```md
  ### My Section
  **Bold** _italic_
  [link](/url)
  ![alt](/img.png)
  > quote

  <details>
  <summary>Summary title</summary>
  Hidden content
  </details>
  ```
- **Gotchas:**
  - Markdown is declarative; paths may be transformed by Docusaurus.
  - Keep `<summary>` on a single line to avoid extra `<p>` tags inside the summary.
  - CommonMark support is experimental.

---

## Admonitions

- **URL:** https://docusaurus.io/docs/markdown-features/admonitions
- **Summary:**
  - Built-in types: `note`, `tip`, `info`, `warning`, `danger`.
  - Add a title with `:::note[Your Title]`.
  - Add attributes/classes/IDs with `:::note{.padding--lg #my-id}`.
  - Use in JSX via `import Admonition from '@theme/Admonition';`.
  - Custom types can be registered in `docusaurus.config.js` and mapped in `src/theme/Admonition/Types.js`.
- **Common syntax:**
  ```md
  :::note
  Your content
  :::

  :::tip[Pro Tip]{.my-class}
  Content with a title and class
  :::

  ::::note Outer
  :::tip Inner
  Nested admonition
  :::
  ::::
  ```
  ```jsx
  import Admonition from '@theme/Admonition';
  <Admonition type="info" title="Custom title">...</Admonition>
  ```
- **Gotchas:**
  - Prettier may auto-format to invalid admonition syntax; add empty lines around opening and closing directives.
  - Nested admonitions need more colons on the parent level (e.g., `::::` for parent, `:::` for child).

---

## Code Blocks

- **URL:** https://docusaurus.io/docs/markdown-features/code-blocks
- **Summary:**
  - Syntax highlighting uses Prism React Renderer with the default Palenight theme; change via `themeConfig.prism.theme`.
  - Only a subset of Prism languages is enabled by default; add more with `themeConfig.prism.additionalLanguages`.
  - Features: titles, line numbers, line highlighting, magic comments, live editor (`jsx live`), npm/yarn tabs (`npm2yarn`).
  - Live code blocks require the `@docusaurus/theme-live-codeblock` theme.
- **Common syntax:**
  ````md
  ```jsx title="/src/components/Hello.js" showLineNumbers {1,4-6,11}
  // highlight-next-line
  function Hello() {
    return <h1>Hello</h1>;
  }
  ```
  ````
  ````md
  ```jsx live
  function Clock() { return <span>Live</span>; }
  ```
  ````
  ```js
  // docusaurus.config.js
  themeConfig: {
    prism: {
      theme: require('prism-react-renderer').themes.dracula,
      additionalLanguages: ['powershell', 'java'],
      magicComments: [
        { className: 'theme-code-block-highlight', line: 'highlight-next-line', block: { start: 'highlight-start', end: 'highlight-end' } },
      ],
    },
  }
  ```
- **Gotchas:**
  - Prefer comment-based highlighting over line-number ranges so edits do not shift highlights.
  - Language names must be valid Prism component names (e.g., `csharp`, not `cs`).
  - In MDX, line breaks inside `<pre>` can collapse to spaces; use `{'\n'}` if needed.
  - For multi-language tabs, leave empty lines around Markdown code blocks.

---

## Tabs

- **URL:** https://docusaurus.io/docs/markdown-features/tabs
- **Summary:**
  - Import `Tabs` and `TabItem` from `@theme/Tabs` and `@theme/TabItem`.
  - Use the `value` prop to identify tabs and the `label` prop for display text.
  - Set a default tab with `default` on a `TabItem` or `defaultValue` on `Tabs`.
  - Sync tabs across pages with `groupId` (persisted in `localStorage`).
  - Control URL query strings with `queryString`.
  - Use `<Tabs lazy />` to avoid rendering hidden tab content until selected.
- **Common syntax:**
  ```mdx
  import Tabs from '@theme/Tabs';
  import TabItem from '@theme/TabItem';

  <Tabs>
    <TabItem value="apple" label="Apple" default>
      This is an apple
    </TabItem>
    <TabItem value="orange" label="Orange">
      This is an orange
    </TabItem>
  </Tabs>
  ```
  ```mdx
  <Tabs groupId="operating-systems" queryString="os" lazy>
    <TabItem value="win" label="Windows">...</TabItem>
    <TabItem value="mac" label="macOS">...</TabItem>
  </Tabs>
  ```
- **Gotchas:**
  - `Tabs` props take precedence over `TabItem` props.
  - `defaultValue` referring to a non-existent value throws an error.
  - If `groupId` values differ across tab groups, the group missing the value will not switch.
  - Query string values take priority over `groupId` persistence on load.

---

## Math Equations

- **URL:** https://docusaurus.io/docs/markdown-features/math-equations
- **Summary:**
  - Equations are rendered with KaTeX.
  - Inline math uses `$...$`; block math uses ` ```math ` fenced code blocks (preferred) or `$$...$$`.
  - Requires `remark-math@6` and `rehype-katex@7` for Docusaurus v3.
  - These plugins are ESM-only; use an ES module config or dynamic imports in CommonJS.
  - Add the KaTeX CSS to `stylesheets`.
- **Common syntax:**
  ```md
  Let $x$ be a variable.

  ```math
  y = mx + b
  ```
  ```
  ```js
  // docusaurus.config.js
  import remarkMath from 'remark-math';
  import rehypeKatex from 'rehype-katex';

  export default {
    stylesheets: ['https://cdn.jsdelivr.net/npm/katex@0.16.0/dist/katex.min.css'],
    presets: [
      ['classic', { docs: { remarkPlugins: [remarkMath], rehypePlugins: [rehypeKatex] } }],
    ],
  };
  ```
- **Gotchas:**
  - Use `remark-math@6` and `rehype-katex@7` specifically for Docusaurus v3.
  - Self-hosting KaTeX CSS and fonts avoids CDN dependency; place them in `static/katex/` and reference `/katex/katex.min.css`.

---

## Diagrams

- **URL:** https://docusaurus.io/docs/markdown-features/diagrams
- **Summary:**
  - Diagrams use Mermaid.
  - Install `@docusaurus/theme-mermaid` and enable `markdown.mermaid: true`.
  - Write Mermaid diagrams in ` ```mermaid ` code blocks.
  - Theming and Mermaid options are configured in `themeConfig.mermaid`.
  - Use the dynamic `<Mermaid>` component from `@theme/Mermaid` for programmatic content.
- **Common syntax:**
  ```js
  // docusaurus.config.js
  export default {
    markdown: { mermaid: true },
    themes: ['@docusaurus/theme-mermaid'],
    themeConfig: {
      mermaid: {
        theme: { light: 'neutral', dark: 'forest' },
        options: { maxTextSize: 50 },
      },
    },
  };
  ```
  ````md
  ```mermaid
  graph TD;
      A-->B;
      A-->C;
      B-->D;
      C-->D;
  ```
  ````
  ```jsx
  import Mermaid from '@theme/Mermaid';
  <Mermaid value={`graph TD; A-->B;`} />
  ```
- **Gotchas:**
  - Default layout engine is `dagre`; for `elk`, install `@mermaid-js/layout-elk` and add a front-matter `config: layout: elk` inside the Mermaid block.
  - Mermaid diagrams are rendered client-side, so they do not affect SSR output.

---

## Assets

- **URL:** https://docusaurus.io/docs/markdown-features/assets
- **Summary:**
  - Co-locate assets next to the Markdown file or place them in configured static directories.
  - Markdown image/link syntax is automatically converted to `require()` calls.
  - In JSX, use `require('./path').default` or ES imports for images/files.
  - Use `pathname://` to disable automatic asset linking for raw URLs.
  - Use `ThemedImage` from `@theme/ThemedImage` for light/dark variants.
  - Inline SVGs can be imported as React components.
- **Common syntax:**
  ```md
  ![alt](./assets/image.png)
  [Download file](./assets/file.docx)
  ```
  ```jsx
  import img from './assets/image.png';
  <img src={img} alt="..." />

  import ThemedImage from '@theme/ThemedImage';
  <ThemedImage
    sources={{
      light: '/img/logo-light.png',
      dark: '/img/logo-dark.png',
    }}
    alt="Logo"
  />
  ```
- **Gotchas:**
  - Only use `require()` in JSX; Markdown syntax handles paths automatically.
  - Absolute paths are resolved from static directories and receive cache-busting hashes via Webpack.
  - Use `pathname:///img/example.png` for plain URLs that should not be processed as assets.

---

## MDX and React

- **URL:** https://docusaurus.io/docs/markdown-features/react
- **Summary:**
  - MDX is built-in; write JSX inside Markdown files.
  - Define components with `export` or import from `@theme`, npm, or `@site/src/components`.
  - Register global components via `@theme/MDXComponents` so they work without per-file imports.
  - Import raw source with `raw-loader` and display it with `@theme/CodeBlock`.
  - Import `.mdx` files as components; prefix partial files with `_`.
  - Available exports: `frontMatter`, `toc`, `contentTitle`.
- **Common syntax:**
  ```mdx
  import MyComponent from '@site/src/components/MyComponent';
  export const Highlight = ({children}) => <span style={{backgroundColor: 'yellow'}}>{children}</span>;

  <Highlight>Highlighted text</Highlight>
  ```
  ```mdx
  import CodeBlock from '@theme/CodeBlock';
  import source from '!!raw-loader!./my-snippet.js';
  <CodeBlock language="js">{source}</CodeBlock>
  ```
- **Gotchas:**
  - MDX v3+ treats lower-case tag names as native HTML elements; custom components must be upper-case.
  - JSX uses double braces for objects: `<span style={{color: 'red'}}>`.
  - Escape `{` and `<` as `\{` and `\<` in literal text.
  - Indented code blocks, autolinks (`<http://...>`), and raw HTML syntax are not supported.
  - When importing Markdown in a React page, wrap it in the `MDXContent` theme component.

---

## Headings

- **URL:** https://docusaurus.io/docs/markdown-features/headings
- **Summary:**
  - Standard Markdown headings create TOC entries.
  - Override auto-generated IDs with explicit heading IDs:
    - MDX: `### Hello World {/* #my-explicit-id */}`
    - CommonMark: `### Hello World {#my-explicit-id}`
  - Bulk-add IDs with `docusaurus write-heading-ids`.
  - TOC level range defaults to h2–h3; override per-page with front matter or globally with `themeConfig.tableOfContents`.
  - Inline TOC uses `<TOCInline toc={toc} />` from `@theme/TOCInline`.
- **Common syntax:**
  ```md
  ### Hello World {#hello-world}
  ```
  ```mdx
  ### Hello World {/* #hello-world */}
  ```
  ```yaml
  ---
  toc_min_heading_level: 2
  toc_max_heading_level: 4
  ---
  ```
  ```js
  themeConfig: {
    tableOfContents: { minHeadingLevel: 2, maxHeadingLevel: 4 },
  }
  ```
  ```jsx
  import TOCInline from '@theme/TOCInline';
  <TOCInline toc={toc} />
  ```
- **Gotchas:**
  - In MDX files, avoid `{#id}`; use the MDX comment syntax. `{#id}` is only kept for compatibility via `markdown.mdx1Compat.headingIds`.
  - Each custom ID must be unique per page; collisions cause errors.
  - Front matter TOC settings only affect the right-hand TOC, not inline TOCs.
  - Headings inside `Tabs` or `<details>` still appear in the TOC; non-Markdown `<h2>` tags do not.

---

## Table of Contents

- **URL:** https://docusaurus.io/docs/markdown-features/toc
- **Summary:**
  - Each Markdown heading becomes a TOC entry by default.
  - Default TOC range is h2–h3.
  - Per-page override: `toc_min_heading_level` and `toc_max_heading_level` front matter.
  - Global override: `themeConfig.tableOfContents`.
  - Inline TOC in MDX: `<TOCInline toc={toc} />` from `@theme/TOCInline`; filter by `level` or heading range.
- **Common syntax:**
  ```yaml
  ---
  toc_min_heading_level: 2
  toc_max_heading_level: 5
  ---
  ```
  ```jsx
  import TOCInline from '@theme/TOCInline';
  <TOCInline
    toc={toc.filter((node) => node.level === 2 || node.level === 4)}
    minHeadingLevel={2}
    maxHeadingLevel={4}
  />
  ```
- **Gotchas:**
  - Front matter settings only affect the page's right-hand TOC, not inline TOCs.
  - Headings rendered inside React components (e.g., `<h2>`) do not appear in the TOC unless they are Markdown headings.
  - Headings inside collapsible areas still appear in the TOC.

---
