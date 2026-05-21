# api integrate

```sh
npm install -g 9router
```

# Vibe Coding

注意，安装时请询问用户安装位置

## 编码

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

包含 15 个 skill：
Engineering:
- diagnose — 诊断硬 bug：复现→最小化→假设→定位→修复→回归测试 → "/diagnose 这个并发崩溃"
- grill-with-docs — 用领域模型挑战你的方案，更新 CONTEXT.md → "/grill-with-docs 审查我的架构设计"
- triage — 通过状态机分流 issue → "/triage 处理积压的 20 个 issue"
- improve-codebase-architecture — 发现代码库中的架构优化机会 → "/improve-codebase-architecture 看看 src/ 怎么重构"
- tdd — 红绿重构 TDD 循环 → "/tdd 用 TDD 实现用户注册功能"
- to-issues — 把方案/PRD 拆成可独立认领的 GitHub issue → "/to-issues 把这个方案拆成 issue"
- to-prd — 把对话上下文转为 PRD 并提交为 issue → "/to-prd 整理刚才讨论的功能写成 PRD"
- zoom-out — 获取不熟悉代码的更高层视角 → "/zoom-out 这个微服务整体架构是什么"
- prototype — 快速构建一次性原型验证设计 → "/prototype 做个 CLI 原型验证交互流程"
Productivity:
- caveman — 超压缩沟通模式，省 ~75% token → "/caveman"
- grill-me — 反复质问你的方案直到决策树完整 → "/grill-me 我的数据库选型方案"
- handoff — 压缩当前对话为交接文档 → "/handoff 生成交接文档"
- write-a-skill — 创建新 skill → "/write-a-skill 写个自动部署的 skill"
Misc:
- git-guardrails-claude-code — 阻止危险 git 命令的 hooks → "/git-guardrails-claude-code"
- setup-pre-commit — 配置 Husky + lint-staged → "/setup-pre-commit"

```sh
# GSD - Get Shit Done
# https://github.com/gsd-build/get-shit-done

# GStack
# https://github.com/garrytan/gstack
```

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

# Find Place

```sh
# skills.sh - Agent Skills Directory (Vercel)
# https://skills.sh
npx skills add vercel-labs/skills --skill find-skills

# claude-code official plugin market
# /plugin marketplace
```
