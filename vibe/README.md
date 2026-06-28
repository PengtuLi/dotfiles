# api integrate

```sh
npm install -g 9router
```

# Vibe Coding

注意，安装时请询问用户安装位置

## 编码

```sh
# Agent-Reach - 给 AI Agent 一键装上互联网能力（网页/YouTube/RSS/GitHub/B站/推特/Reddit 等）
# https://github.com/Panniantong/Agent-Reach
# 安装方式：让 AI agent 读取 https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/install.md 并执行安装
```

```sh
# Anthropic 官方 skills（必装）
# https://github.com/anthropics/skills
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
```

包含 17 个 skill：
- **pdf** — PDF 读取、合并、拆分、水印 → "帮我把这 3 个 PDF 合并"
- **pptx** — PPT 创建、编辑、模板 → "做一个 10 页产品介绍 PPT"
- **docx** — Word 文档创建与编辑 → "生成一份合同文档"
- **xlsx** — Excel 表格处理（含 csv/tsv） → "整理这个表格加上公式"
- **claude-api** — Claude API / Anthropic SDK 开发 → "帮我用 Anthropic SDK 写个 agent"
- **mcp-builder** — MCP Server 构建 → "创建一个连接数据库的 MCP Server"
- **skill-creator** — 创建和优化 skill → "帮我写一个新的 skill"
- **frontend-design** — 高质量前端界面 → "做一个好看的 Dashboard 页面"
- **web-artifacts-builder** — 复杂 HTML artifacts（React/Tailwind/shadcn） → "用 React + shadcn 做个表单"
- **webapp-testing** — Playwright Web 应用测试 → "测试这个页面的登录流程"
- **canvas-design** — 视觉设计（png/pdf） → "设计一张海报"
- **algorithmic-art** — p5.js 生成艺术 → "生成一个粒子流场动画"
- **theme-factory** — 主题样式工具 → "给这个 PPT 换个暗色主题"
- **brand-guidelines** — Anthropic 品牌规范 → "按 Anthropic 品牌风格调整配色"
- **doc-coauthoring** — 文档协作撰写 → "一起写一份技术方案文档"
- **internal-comms** — 内部沟通文档 → "写一封项目进度汇报邮件"
- **slack-gif-creator** — Slack 动图制作 → "做个庆祝上线的 Slack GIF"

```sh
# Matt Pocock 大神技能
# https://github.com/mattpocock/skills
npx skills@latest add mattpocock/skills
# 安装后运行 /setup-matt-pocock-skills 配置
```

设计哲学：小、可组合、适配任意模型，不接管流程，只解决真实工程中的常见失败模式。

安装后运行 `/setup-matt-pocock-skills` 配置 issue tracker（GitHub/Linear/本地文件）、triage 标签和文档保存位置。

**Engineering（用户触发）**

- **ask-matt** — 路由到当前场景最适合的技能 → "/ask-matt"
- **grill-with-docs** — 拷问方案并构建项目领域模型，更新 CONTEXT.md 和 ADR → "/grill-with-docs 审查我的架构设计"
- **triage** — 通过状态机分流 issue → "/triage 处理积压的 20 个 issue"
- **improve-codebase-architecture** — 扫描代码库中的架构深化机会，生成可视化 HTML 报告 → "/improve-codebase-architecture 看看 src/ 怎么重构"
- **setup-matt-pocock-skills** — 首次配置本仓库 → "/setup-matt-pocock-skills"
- **to-issues** — 把方案/PRD 拆成可独立认领的 issue → "/to-issues 把这个方案拆成 issue"
- **to-prd** — 把当前对话上下文转为 PRD 并提交到 issue tracker → "/to-prd 整理刚才讨论的功能写成 PRD"

**Engineering（模型自动触发）**

- **prototype** — 快速构建一次性原型验证设计 → "/prototype 做个 CLI 原型验证交互流程"
- **diagnosing-bugs** — 硬 bug 与性能回归的诊断循环：复现→最小化→假设→定位→修复→回归测试 → "/diagnosing-bugs 这个并发崩溃"
- **tdd** — 红绿重构 TDD 循环，一次一个垂直切片 → "/tdd 用 TDD 实现用户注册功能"
- **domain-modeling** — 主动构建和打磨领域模型，挑战术语并更新 CONTEXT.md → "/domain-modeling"
- **codebase-design** — 设计深模块：小接口、大行为、干净接缝、可测试 → "/codebase-design"

**Productivity（用户触发）**

- **grill-me** — 反复质问你的方案直到决策树完整 → "/grill-me 我的数据库选型方案"
- **handoff** — 压缩当前对话为交接文档 → "/handoff 生成交接文档"
- **teach** — 在多会话中教用户新技能或概念，以当前目录为教学工作区 → "/teach 我想学 React Server Components"
- **writing-great-skills** — 编写高质量 skill 的参考手册 → "/writing-great-skills"

**Productivity（模型自动触发）**

- **grilling** — 反复质问直到决策树完整，grill-me / grill-with-docs 的复用循环

**Misc**

- **git-guardrails-claude-code** — 阻止危险 git 命令的 hooks → "/git-guardrails-claude-code"
- **migrate-to-shoehorn** — 把测试里的 `as` 类型断言迁移到 @total-typescript/shoehorn → "/migrate-to-shoehorn"
- **scaffold-exercises** — 创建包含章节、题目、解答和讲解的练习目录结构 → "/scaffold-exercises"
- **setup-pre-commit** — 配置 Husky pre-commit hooks + lint-staged + Prettier + 类型检查 + 测试 → "/setup-pre-commit"

```sh
# GSD - Get Shit Done
# https://github.com/gsd-build/get-shit-done

# GStack
# https://github.com/garrytan/gstack
```

```sh
# Addy Osmani - 生产级工程技能（24 skills）
# https://github.com/addyosmani/agent-skills
/plugin marketplace add addyosmani/agent-skills
/plugin install agent-skills@addy-agent-skills
```

包含 24 个 skill，覆盖完整开发流程 DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP：

**定义阶段**
- **interview-me** — 逐题访谈提取真实需求 → "/interview-me 帮我定义这个功能"
- **idea-refine** — 结构化发散/收敛思维，将模糊想法转为具体提案 → "/idea-refine 优化这个方案"
- **spec-driven-development** — 编写涵盖目标、命令、结构、代码风格、测试和边界的 PRD → "/spec"

**规划阶段**
- **planning-and-task-breakdown** — 将规格分解为带验收标准和依赖排序的小型可验证任务 → "/plan"

**构建阶段**
- **incremental-implementation** — 薄垂直切片——实现、测试、验证、提交 → "/build"
- **test-driven-development** — 红-绿-重构，测试金字塔（80/15/5） → "/test"
- **context-engineering** — 在正确时间向代理提供正确信息 → "/context"
- **source-driven-development** — 每个框架决策基于官方文档 → "/source"
- **doubt-driven-development** — 对抗性新上下文审查 → "/doubt"
- **frontend-ui-engineering** — 组件架构、设计系统、状态管理、响应式设计、WCAG 2.1 AA → "/frontend"
- **api-and-interface-design** — 契约优先设计、Hyrum 定律、单版本规则 → "/api"

**验证阶段**
- **browser-testing-with-devtools** — Chrome DevTools MCP 实时运行时数据 → "/webperf"
- **debugging-and-error-recovery** — 五步分类：重现、定位、缩减、修复、防护 → "/debug"

**审查阶段**
- **code-review-and-quality** — 五轴审查，变更规模约 100 行 → "/review"
- **code-simplification** — Chesterton 栅栏，500 规则，降低复杂度 → "/code-simplify"
- **security-and-hardening** — OWASP Top 10 预防、认证模式、密钥管理 → "/security"
- **performance-optimization** — Core Web Vitals 目标、分析工作流、包分析 → "/perf"

**发布阶段**
- **git-workflow-and-versioning** — 基于主干的开发、原子提交 → "/git"
- **ci-cd-and-automation** — 左移、功能标志、质量门禁流水线 → "/cicd"
- **deprecation-and-migration** — 代码即负债思维、强制与建议弃用 → "/deprecate"
- **documentation-and-adrs** — 架构决策记录、API 文档、内联文档标准 → "/docs"
- **observability-and-instrumentation** — 结构化日志、RED 指标、OpenTelemetry → "/observability"
- **shipping-and-launch** — 发布前检查清单、分阶段推出、回滚程序 → "/ship"

> **对比**：与 Matt Pocock skills 和 Superpowers 相比，agent-skills 覆盖**完整产品生命周期**（需求→发布），每个阶段设有人类检查点；Superpowers 押注自主推理，适合长周期自主运行；Matt Pocock 则是低仪式感的个人实战工具箱。三者可"点菜"混用（如引入 Matt 的 `grill-me`、Superpowers 的子代理隔离），但不要同时运行两个作为主动路由，否则元技能会争夺命令名。

## 领域技能

```sh
# AI 研究 98 skills
# https://github.com/Orchestra-Research/AI-Research-SKILLs
npx @orchestra-research/ai-research-skills

# 科学研究 135 skills（更全）
# https://github.com/K-Dense-AI/scientific-agent-skills
npx skills add K-Dense-AI/scientific-agent-skills
```

## PPT 制作

```sh
# 复杂 PPT 生成
# https://github.com/hugohe3/ppt-master
npx skills add hugohe3/ppt-master

# HTML PPT
# https://github.com/op7418/guizang-ppt-skill
npx skills add https://github.com/op7418/guizang-ppt-skill --skill guizang-ppt-skill

```

## Research

```sh
# 多来源搜索
# https://github.com/mvanhorn/last30days-skill
npx skills add mvanhorn/last30days-skill -g
```

## 本地 skills

- `./CLAUDE.md` Karpathy 编码风格（必装）— https://github.com/forrestchang/andrej-karpathy-skills
- `./skills/paper-glance-skill/` 论文全能处理（分析、思维导图、审稿、播客） → "帮我看这篇论文" / "上传 PDF 做审稿"
- `./skills/academic-pptx-skill/` 学术 PPT 内容与结构 — https://github.com/Gabberflast/academic-pptx-skill → "帮我做一篇关于 X 论文的会议演讲 PPT"
- `./skills/excalidraw-diagram-generator/` 自然语言生成 Excalidraw 图表 — 来自 copilot-awesome → "画一个用户注册流程图" / "创建 AWS 架构图"
- `./skills/brainstorming/` 创意工作前的需求探索与设计 — 来自 superpower → "我想加一个用户积分系统，帮我设计一下"
- `./skills/understand-project/` 系统化理解新代码库（全局认知→跑起来→数据流架构→约定边界→动手实践） → "帮我理解这个项目" / "我刚接触这个代码库，带我过一遍"
- `./skills/add-educational-comments/` 为代码添加教学注释（按知识水平生成中文教育性注释） → "给 main.py 添加教学注释"
- `./skills/mermaid-diagrams/` Mermaid 图表语法参考与最佳实践（9+ 图表类型） — https://github.com/softaworks/agent-toolkit → "画一个登录认证的时序图" / "用 Mermaid 画出数据库 ER 图"
- `./skills/brag-sheet/` 把工作记录变成证据支持的绩效陈述（三部分影响契约：行动→结果→证据） — 来自 copilot-awesome → "帮我回顾这周做了什么" / "准备绩效自评"
- `./skills/documentation-writer/` 基于 Diátaxis 框架的文档写作（教程/操作指南/参考/解释四类） — 来自 copilot-awesome → "写一个 API 参考文档" / "给新功能写个教程"
- `./skills/arch-linux-triage/` Arch Linux 系统排障（pacman、滚动更新、systemd） — 来自 copilot-awesome → "Arch 更新后网卡不工作了"
- `./skills/python-performance-optimization/` Python 性能优化（cProfile、内存分析、NumPy 向量化、async IO 等 20 个优化模式） — 来自 wshobson/agents → "这个 Python 脚本跑得太慢了，帮我优化" / "分析一下这个函数的内存占用"
- `./skills/secure-linux-web-hosting/` Linux Web 服务器安全搭建（SSH 加固、Nginx、HTTPS/Let's Encrypt、跨发行版路由） — 来自 xixu-me/skills → "帮我在云服务器上搭建一个安全的 Nginx 站点" / "给服务器配上 HTTPS 证书"
- `./skills/ssh-server-and-container-setup/` SSH 远程配置 Linux 服务器用户和 Docker 容器（用户创建、公钥部署、GPU 容器创建、容器内 SSH 配置、本地 ~/.ssh/config 管理） → "配置服务器创建容器" / "给服务器添加新用户"
- `./skills/huggingface-papers/` HuggingFace 论文查找与阅读（HF/arXiv URL 解析、结构化元数据、作者/关联模型/数据集） — https://github.com/huggingface/skills → "帮我看看这篇论文 2602.08025" / "解释一下这个 HF paper"
- `./skills/ai-model-download/` AI 模型下载与管理（HuggingFace 和 ModelScope 双平台、批量下载、断点续传、完整性校验、参数量统计） → "从 HF 下载 Qwen 模型" / "帮我上传模型到 ModelScope"
- `./skills/caveman-review/` 超压缩 PR 代码审查（一行一评：位置+问题+修复，emoji 严重度标记） → "review this PR" / "code review" / "/caveman-review"

# Find Place

```sh
# skills.sh - Agent Skills Directory (Vercel)
# https://skills.sh
npx skills add vercel-labs/skills --skill find-skills

# claude-code official plugin market
# /plugin marketplace
```
