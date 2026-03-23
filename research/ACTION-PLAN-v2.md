# harness-kit 行动计划书 v2.0

> **基于深度研究的升级版** | 2026-03-23
> v1.0 → v2.0 变更：新增研究洞察审视、补充关键缺失组件、细化每个任务到可执行文件级别、增加验收标准和风险缓解

---

## 零、v1.0 计划审视：研究洞察对计划的修正

基于 4 份研究报告的深度分析，v1.0 计划有以下需要修正和补充的关键点：

### 修正 1：AGENTS.md 模板需要更强调"反应式"本质

**研究发现**：Hashimoto 的原始定义是**反应式**的 —— "每当发现 Agent 犯错，就工程化一个解决方案"。Ghostty 的 AGENTS.md 只有 4 行，每行对应一个具体的 Agent 错误行为。ETH Zurich 研究发现 LLM 生成的 AGENTS.md 反而**降低**性能 20%+，而人工编写的仅提升约 4%。

**修正**：模板不应该是"填空题"，而是附带**编写方法论** —— 教用户如何通过观察 Agent 失败来迭代式编写 AGENTS.md。增加"错误驱动编写法"指南。

### 修正 2：缺少 Hooks/中间件层

**研究发现**：LangChain Terminal Bench 提升的核心是三个旋钮：**System Prompt、Tools、Middleware**。Claude Code 有 24+ 生命周期钩子点和 4 种处理器类型。Stripe 的 Blueprints 是确定性节点与 Agent 节点的状态机混合。

**修正**：新增 `templates/hooks/` 目录，包含 Claude Code hooks、PreToolUse/PostToolUse/Stop 等关键钩子模板。这是 v1.0 **最大的遗漏**。

### 修正 3：缺少 Skills（渐进式上下文披露）层

**研究发现**：LangChain 测试显示 Claude Code 有 Skills 时任务完成率 82%，无 Skills 时仅 9%。12 个整合的 Skills 优于 20 个碎片化的。Skills 是渐进式披露的核心实现。

**修正**：新增 `templates/skills/` 目录，包含常见任务类型的 Skill 模板。

### 修正 4：缺少"推理计算优化"维度

**研究发现**：LangChain 的 "xhigh-high-xhigh 推理三明治" 策略（规划和验证用高算力，实现用低算力）将分数从 63.6% 提升到 66.5%。这是 Harness 的一部分。

**修正**：在 guides/ 中增加推理模式优化指南。

### 修正 5：过度强调"100% 测试覆盖率"

**研究发现**：OpenAI 的哲学是 "corrections are cheap, and waiting is expensive"（纠正成本低，等待成本高）。Stripe 刻意限制最多 2 轮 CI 修复。HumanLayer 研究发现"每次会话都运行完整测试套件"是**不可行**的做法。

**修正**：将"100% 测试覆盖率"改为"快速反馈优先"策略 —— 关键路径测试 < 1 分钟，完整测试在 CI 中运行。

### 修正 6：需要增加"控制幻觉"警告

**研究发现**：Böckeler 明确指出"控制幻觉（Illusion of Control）" —— 尽管叫"工程"，执行仍依赖 LLM 的解读。上下文工程提高的是概率，不能保证结果。

**修正**：在 philosophy.md 中增加"概率思维"章节，帮助用户建立正确预期。

### 修正 7：仓库结构需增加平台适配层

**研究发现**：不同平台的规则文件格式不同 —— Claude Code 用 CLAUDE.md，Cursor 用 .cursorrules，Copilot 用 copilot-instructions.md，Codex 用 AGENTS.md。一个好的工具包需要提供**跨平台适配**。

**修正**：新增 `templates/platform-adapters/` 目录。

---

## 一、项目概述（不变）

- **项目名称**：harness-kit
- **License**：MIT
- **定位**：开箱即用的 Harness Engineering 工具包
- **一句话描述**：Don't spend 5 months building your harness from scratch. Start with harness-kit.

---

## 二、升级后的仓库结构 v2.0

```
harness-kit/
├── README.md                         # 项目介绍 + 快速开始
├── README-zh.md                      # 中文版 README
├── LICENSE                           # MIT
├── CONTRIBUTING.md                   # 贡献指南
├── CLAUDE.md                         # 本项目自身的 Harness（dog-fooding）
├── AGENTS.md                         # 本项目自身的 Agent 指南（dog-fooding）
│
├── templates/                        # ===== 核心模板 =====
│   │
│   ├── agents-md/                    # AGENTS.md 模板
│   │   ├── minimal.md               # 极简版（5-10行，小项目）
│   │   ├── standard.md              # 标准版（~100行，中型项目）
│   │   ├── monorepo.md              # 单仓多包版（含嵌套指南）
│   │   ├── writing-guide.md         # 🆕 错误驱动编写法指南
│   │   └── examples/                # 真实项目示例
│   │       ├── web-app.md           #   React/Next.js Web 应用
│   │       ├── api-service.md       #   REST/GraphQL API 服务
│   │       ├── data-pipeline.md     #   ETL/数据管道
│   │       ├── mobile-app.md        #   React Native/Flutter 移动应用
│   │       ├── cli-tool.md          #   命令行工具
│   │       └── ml-project.md        #   机器学习项目
│   │
│   ├── knowledge-base/              # 知识库目录结构模板
│   │   ├── docs/
│   │   │   ├── ARCHITECTURE.md      # 架构文档模板
│   │   │   ├── QUALITY.md           # 质量评分模板（按模块打分）
│   │   │   ├── BELIEFS.md           # 核心信念/黄金原则模板
│   │   │   ├── TECH-DEBT.md         # 🆕 技术债登记簿模板
│   │   │   ├── designs/
│   │   │   │   └── TEMPLATE.md      # 设计文档模板（含验证状态字段）
│   │   │   └── plans/
│   │   │       ├── PLANS.md         # ExecPlan 模板（基于 OpenAI 规范）
│   │   │       └── TEMPLATE.md      # 单个执行计划模板
│   │   └── README.md                # 知识库使用说明
│   │
│   ├── hooks/                        # 🆕 Hooks/中间件模板
│   │   ├── README.md                 # Hooks 体系概述
│   │   ├── claude-code/              # Claude Code Hooks
│   │   │   ├── settings-hooks.json   #   settings.json hooks 配置模板
│   │   │   ├── pre-tool-use/         #   PreToolUse 钩子
│   │   │   │   ├── block-destructive.sh   # 阻止危险命令（rm -rf等）
│   │   │   │   ├── restrict-paths.sh      # 限制编辑路径
│   │   │   │   └── validate-imports.sh    # 验证导入规则
│   │   │   ├── post-tool-use/        #   PostToolUse 钩子
│   │   │   │   ├── auto-lint.sh           # 每次编辑后自动lint
│   │   │   │   ├── auto-format.sh         # 每次编辑后自动格式化
│   │   │   │   └── log-changes.sh         # 记录所有文件变更
│   │   │   ├── stop/                 #   Stop 钩子（验证门）
│   │   │   │   ├── require-tests.sh       # 停止前必须通过测试
│   │   │   │   ├── require-lint.sh        # 停止前必须通过lint
│   │   │   │   └── require-build.sh       # 停止前必须通过构建
│   │   │   └── session-start/        #   SessionStart 钩子
│   │   │       └── setup-env.sh           # 会话开始时初始化环境
│   │   │
│   │   └── middleware-patterns/       # 🆕 中间件模式（跨平台）
│   │       ├── loop-detection.md          # 循环检测中间件
│   │       ├── pre-completion-checklist.md # 完成前检查清单
│   │       ├── time-budgeting.md          # 时间预算管理
│   │       └── reasoning-sandwich.md      # 推理计算三明治策略
│   │
│   ├── skills/                       # 🆕 Skills（渐进式披露）模板
│   │   ├── README.md                 # Skills 设计原则
│   │   ├── claude-code/              # Claude Code Skills
│   │   │   ├── code-review.md        #   代码审查 Skill
│   │   │   ├── test-writing.md       #   测试编写 Skill
│   │   │   ├── refactoring.md        #   重构 Skill
│   │   │   ├── debugging.md          #   调试 Skill
│   │   │   ├── api-design.md         #   API 设计 Skill
│   │   │   ├── database-migration.md #   数据库迁移 Skill
│   │   │   ├── doc-writing.md        #   文档编写 Skill
│   │   │   ├── security-audit.md     #   安全审计 Skill
│   │   │   ├── performance-opt.md    #   性能优化 Skill
│   │   │   ├── ci-fix.md             #   CI 修复 Skill
│   │   │   ├── ui-implementation.md  #   UI 实现 Skill
│   │   │   └── entropy-cleanup.md    #   熵清理 Skill
│   │   └── design-principles.md      # 12个整合 > 20个碎片化
│   │
│   ├── constraints/                  # 架构约束模板
│   │   ├── layer-rules.md            # 分层依赖规则模板
│   │   ├── linter-guide.md           # 定制 Linter 编写指南（Agent 友好错误消息）
│   │   ├── error-message-design.md   # 🆕 Agent 友好错误消息设计指南
│   │   └── examples/
│   │       ├── eslint-custom/        # ESLint 自定义规则示例
│   │       │   ├── rules/
│   │       │   │   ├── layer-dependency.js     # 分层依赖检查
│   │       │   │   ├── max-file-length.js      # 文件长度限制
│   │       │   │   └── require-error-context.js # 错误消息必须含上下文
│   │       │   ├── formatters/
│   │       │   │   └── agent-friendly.js       # Agent 友好格式化器
│   │       │   └── .eslintrc.js
│   │       ├── ruff-custom/          # Python Ruff 自定义规则示例
│   │       └── structural-tests/     # 结构测试示例
│   │           ├── typescript/       #   TS 架构测试
│   │           └── python/           #   Python 架构测试
│   │
│   ├── entropy/                      # 熵管理模板
│   │   ├── cleanup-agent-prompt.md   # 清理 Agent Prompt 模板
│   │   ├── doc-gardener-prompt.md    # 文档园丁 Agent Prompt
│   │   ├── golden-principles.md      # 黄金原则模板
│   │   ├── quality-grades.md         # 质量评分标准（A/B/C/D/F）
│   │   ├── weekly-entropy-review.md  # 🆕 每周熵审计清单
│   │   └── anti-patterns.md          # 🆕 常见熵累积反模式
│   │
│   ├── environments/                 # 环境隔离模板
│   │   ├── worktree-setup.sh         # Git worktree 一键脚本
│   │   ├── new-feature.sh            # 新功能环境创建脚本
│   │   ├── teardown.sh               # 🆕 任务完成后自动销毁脚本
│   │   ├── docker-compose.yml        # 隔离环境 Docker 模板
│   │   └── devbox-config.md          # 🆕 Devbox 配置指南（参考 Stripe 模式）
│   │
│   └── platform-adapters/            # 🆕 跨平台适配层
│       ├── README.md                 # 各平台规则文件对照表
│       ├── claude-code/              # Claude Code 适配
│       │   ├── CLAUDE.md.template
│       │   ├── rules/                # .claude/rules/ 目录模板
│       │   └── settings.json.template
│       ├── cursor/                   # Cursor 适配
│       │   └── .cursorrules.template
│       ├── copilot/                  # GitHub Copilot 适配
│       │   ├── copilot-instructions.md.template
│       │   └── instructions/         # .github/instructions/ 目录模板
│       └── codex/                    # OpenAI Codex 适配
│           └── AGENTS.md.template
│
├── tools/                            # ===== 可执行工具 =====
│   ├── harness-score/                # Harness 成熟度评分工具
│   │   ├── README.md
│   │   ├── scorer.py                 # 评分引擎
│   │   ├── dimensions.yaml           # 评分维度定义（8 层）
│   │   ├── checklist.md              # 🆕 纸质版 checklist（MVP 前可用）
│   │   └── report-template.md        # 报告模板
│   │
│   ├── harness-init/                 # 🆕 一键初始化工具
│   │   ├── README.md
│   │   ├── init.py                   # 交互式初始化脚本
│   │   └── presets/                  # 预设配置
│   │       ├── minimal.yaml          # 极简预设
│   │       ├── standard.yaml         # 标准预设
│   │       └── enterprise.yaml       # 企业级预设
│   │
│   ├── linter-gen/                   # Linter 规则生成器
│   │   ├── README.md
│   │   └── generate.py               # 输入约束 → 输出 Linter 规则
│   │
│   └── entropy-scanner/              # 熵扫描器
│       ├── README.md
│       ├── scan.py                    # 文档漂移 + 架构违规扫描
│       ├── detectors/                 # 🆕 可插拔检测器
│       │   ├── doc-drift.py           # 文档漂移检测
│       │   ├── rule-conflict.py       # 规则冲突检测
│       │   ├── dead-rules.py          # 死规则检测
│       │   └── dependency-decay.py    # 依赖退化检测
│       └── report-template.md
│
├── guides/                           # ===== 指南文档 =====
│   ├── getting-started.md            # 5 分钟快速开始
│   ├── getting-started-zh.md         # 🆕 中文版快速开始
│   ├── agents-md-guide.md            # AGENTS.md 编写完全指南
│   ├── error-driven-writing.md       # 🆕 错误驱动编写法（核心方法论）
│   ├── progressive-disclosure.md     # 渐进式披露设计指南
│   ├── hooks-and-middleware.md        # 🆕 Hooks 与中间件完全指南
│   ├── skills-design.md              # 🆕 Skills 设计与优化指南
│   ├── reasoning-optimization.md     # 🆕 推理计算优化指南
│   ├── from-zero-to-harness.md       # 从零开始的 Harness 搭建路径
│   ├── retrofitting.md               # 给现有项目加装 Harness
│   ├── philosophy.md                 # 方法论与哲学
│   │                                 #   含：三代演进、严谨性迁移、
│   │                                 #   概率思维、控制幻觉警告
│   ├── anti-patterns.md              # 🆕 Harness 反模式指南
│   │                                 #   含：过度约束、LLM生成规则、
│   │                                 #   超40%上下文占用、预设万能配置
│   └── platform-comparison.md        # 🆕 各 Agent 平台 Harness 能力对比
│
├── ci/                               # ===== CI 集成模板 =====
│   ├── github-actions/
│   │   ├── harness-check.yml         # Harness 健康检查 workflow
│   │   ├── entropy-scan.yml          # 定期熵扫描 workflow
│   │   ├── doc-gardener.yml          # 文档园丁定期运行
│   │   └── agent-code-review.yml     # 🆕 Agent 代码审查 workflow
│   └── gitlab-ci/
│       └── harness-check.yml
│
└── research/                         # ===== 调研资料 =====
    ├── harness-engineering-research.md     # 综合研究报告
    ├── research-01-mitchell-hashimoto.md   # Hashimoto 研究
    ├── research-02-openai-langchain.md     # OpenAI + LangChain 研究
    ├── research-03-thoughtworks-industry.md # Thoughtworks + 行业研究
    ├── research-04-technical-practices.md  # 技术实践研究
    └── *-zh.md                             # 上述文件的中文版
```

### v2.0 vs v1.0 结构对比

| 组件 | v1.0 | v2.0 | 变化原因 |
|------|------|------|---------|
| templates/hooks/ | 无 | 完整的 4 类钩子模板 | LangChain 研究：中间件是性能提升三大旋钮之一 |
| templates/skills/ | 无 | 12 个 Skill 模板 | LangChain：82% vs 9% 任务完成率差异 |
| templates/platform-adapters/ | 无 | 4 平台适配模板 | 研究发现各平台规则文件格式不同 |
| tools/harness-init/ | 无 | 一键初始化工具 | 降低"5分钟搭建"的门槛 |
| guides/error-driven-writing.md | 无 | 核心方法论指南 | Hashimoto：AGENTS.md 应反应式编写 |
| guides/anti-patterns.md | 无 | 反模式指南 | ETH Zurich：LLM 生成的规则降低性能 |
| guides/hooks-and-middleware.md | 无 | Hooks 完全指南 | Claude Code 24+ 生命周期钩子 |
| CLAUDE.md + AGENTS.md（项目自身） | 无 | Dog-fooding | 自己用自己的模板，最佳说服力 |

---

## 三、评分维度定义（Harness 成熟度模型）

基于研究提炼的 **8 层 Harness 成熟度模型**，作为 harness-score 工具的评分框架：

```
Level 0: 无 Harness（裸跑 Agent）
Level 1: 规则层 — 有 AGENTS.md/CLAUDE.md 等规则文件
Level 2: 约束层 — 有 Linter + 类型检查 + Pre-commit Hooks
Level 3: 验证层 — Agent 可运行测试并自检
Level 4: 反馈层 — 错误消息含修复建议，形成闭环
Level 5: 上下文层 — Skills 渐进披露 + 路径特定规则
Level 6: 环境层 — 隔离执行环境（worktree/devbox/container）
Level 7: 自治层 — 熵管理 + 多 Agent 协调 + 长时间运行支撑
```

每层评分 0-10，总分 0-80，划分等级：

| 等级 | 分数 | 描述 |
|------|------|------|
| F | 0-15 | 无 Harness，Agent 裸跑 |
| D | 16-30 | 基础规则，缺乏执行力 |
| C | 31-45 | 有约束和验证，但反馈不闭环 |
| B | 46-60 | 完整反馈闭环，有上下文管理 |
| A | 61-70 | 隔离环境 + 熵管理 |
| S | 71-80 | 全自治级别（OpenAI/Stripe 水平） |

---

## 四、分阶段详细执行计划

### Phase 0：Dog-Fooding 准备（第 0 天）

**目标**：项目自身就是 Harness Engineering 的示范

| # | 任务 | 具体产出 | 验收标准 |
|---|------|---------|---------|
| 0.1 | 创建 GitHub 仓库 | 仓库 + .gitignore + LICENSE (MIT) | 仓库可访问 |
| 0.2 | 编写项目自身的 CLAUDE.md | `/CLAUDE.md` | Claude Code 读取时能正确遵循项目约定 |
| 0.3 | 编写项目自身的 AGENTS.md | `/AGENTS.md` | 任何 Agent 打开仓库都知道如何贡献 |
| 0.4 | 搬入已有研究资料 | `/research/` 全套（含中文版） | 所有研究文件可访问 |
| 0.5 | 编写初版 README.md | 项目介绍 + 愿景 + 结构预览 | 读者 30 秒内理解项目定位 |

**0.2 CLAUDE.md 详细内容规划**：
```markdown
# CLAUDE.md for harness-kit

## 项目概述
harness-kit 是 Harness Engineering 工具包...

## 技术栈
- 文档：Markdown（所有模板）
- 工具：Python 3.11+（CLI 工具）
- Linter 示例：ESLint (JS/TS) + Ruff (Python)
- CI：GitHub Actions

## 编写约定
- 模板文件使用 Markdown，前置 YAML frontmatter 描述元数据
- Python 工具使用 ruff 格式化，类型注解必须
- 所有模板必须附带「何时使用」和「何时不用」说明
- 引用原文保留英文，中文版单独文件

## 测试
- Python 工具：pytest，运行 `python -m pytest tools/`
- 模板验证：markdownlint，运行 `npx markdownlint 'templates/**/*.md'`

## 禁止事项
- 不要生成通用的空洞建议，每条规则必须有具体实例
- 不要把 AGENTS.md 写成百科全书，目标是 ~100 行
- 不要用 LLM 自动生成规则文件内容（ETH Zurich 研究证明会降低性能）
```

---

### Phase 1：核心模板 V0.1（第 1 周）

**目标**：完成最核心的三样交付物 —— AGENTS.md 模板 + 错误驱动编写法 + 快速开始指南

**交付标准**：Clone 后 5 分钟内能给自己的项目加上基础 Harness

| # | 任务 | 产出文件 | 工时 | 详细说明 |
|---|------|---------|------|---------|
| 1.1 | AGENTS.md 极简模板 | `templates/agents-md/minimal.md` | 1h | 5-10 行，适合个人小项目。参考 Ghostty 实例风格 |
| 1.2 | AGENTS.md 标准模板 | `templates/agents-md/standard.md` | 3h | ~100 行，OpenAI "目录而非百科" 原则，含渐进式披露目录结构 |
| 1.3 | AGENTS.md 单仓模板 | `templates/agents-md/monorepo.md` | 2h | 参考 OpenAI 88 个 AGENTS.md 的嵌套策略 |
| 1.4 | 错误驱动编写法指南 | `templates/agents-md/writing-guide.md` + `guides/error-driven-writing.md` | 4h | **核心方法论**。Hashimoto 的反应式方法 + 具体操作步骤 |
| 1.5 | 知识库结构模板 | `templates/knowledge-base/` 全套 | 4h | ARCHITECTURE.md, QUALITY.md, BELIEFS.md, PLANS.md 等 |
| 1.6 | 快速开始指南 | `guides/getting-started.md` | 3h | 5 分钟路径：选模板 → 复制 → 修改 → 运行验证 |
| 1.7 | 方法论指南 | `guides/philosophy.md` | 4h | 三代演进 + 严谨性迁移 + 概率思维 + 控制幻觉 |
| 1.8 | 中文版快速开始 | `guides/getting-started-zh.md` | 2h | 中文版 |

**1.4 错误驱动编写法详细大纲**：

```
# 错误驱动编写法：如何写出有效的 AGENTS.md

## 核心原则
> "每一行规则都应该对应一个你观察到的具体 Agent 失败。" — Mitchell Hashimoto

## 四步循环
1. 观察：让 Agent 执行任务，记录它犯的错
2. 分析：这个错误是信息缺失、约束缺失还是工具缺失？
3. 编写：针对具体错误写一条规则/工具
4. 验证：让 Agent 重新执行同一任务，确认错误消失

## 什么不该写
- ❌ 通用的编程最佳实践（Agent 已经知道）
- ❌ LLM 自动生成的规则（ETH Zurich：降低性能 20%+）
- ❌ 超过 200 行（重要规则被噪音淹没）
- ❌ 假设性的规则（"可能会犯的错"）

## 什么应该写
- ✅ Agent 实际犯过的错误的修正指令
- ✅ 项目特有的命令和路径（Agent 无法猜到的）
- ✅ 验证方法（怎么确认做对了）
- ✅ 不存在的东西（如 "本包没有单元测试"）

## 真实案例分析
### 案例 1：Ghostty Inspector（4 行解决 4 个问题）
### 案例 2：OpenAI Codex（~100 行目录式）
### 案例 3：Stripe Minions（目录级作用域）

## 反模式
- 💀 "填空模板法"：提前写好空洞的模板让人填空
- 💀 "AI 写 AI 规则"：用 Agent 生成自己的规则文件
- 💀 "百科全书法"：把所有能想到的都写进去
```

---

### Phase 2：Hooks + Skills + 约束（第 2-3 周）

**目标**：三大性能杠杆全覆盖 —— Hooks（确定性执行）、Skills（渐进披露）、架构约束（机械化边界）

**交付标准**：harness-score checklist 可对任意项目评分

| # | 任务 | 产出文件 | 工时 | 详细说明 |
|---|------|---------|------|---------|
| **Hooks 体系** |
| 2.1 | Hooks 概述文档 | `templates/hooks/README.md` | 2h | 4 种处理器类型 + 24+ 生命周期点概览 |
| 2.2 | PreToolUse 钩子模板 | `templates/hooks/claude-code/pre-tool-use/` (3 个) | 3h | 阻止危险命令、限制路径、验证导入 |
| 2.3 | PostToolUse 钩子模板 | `templates/hooks/claude-code/post-tool-use/` (3 个) | 3h | 自动 lint、自动格式化、变更日志 |
| 2.4 | Stop 钩子模板（验证门） | `templates/hooks/claude-code/stop/` (3 个) | 3h | 必须通过测试/lint/构建才能停止 |
| 2.5 | Hooks 完全指南 | `guides/hooks-and-middleware.md` | 4h | 从零开始配置 Hooks 的完整教程 |
| 2.6 | 中间件模式文档 | `templates/hooks/middleware-patterns/` (4 个) | 4h | 循环检测、完成前检查、时间预算、推理三明治 |
| **Skills 体系** |
| 2.7 | Skills 设计原则 | `templates/skills/README.md` + `templates/skills/design-principles.md` | 3h | "12 个整合 > 20 个碎片化" 原则 |
| 2.8 | 核心 Skills 模板（前 6 个） | `templates/skills/claude-code/` (6 个) | 6h | 代码审查、测试编写、重构、调试、API 设计、CI 修复 |
| 2.9 | 扩展 Skills 模板（后 6 个） | `templates/skills/claude-code/` (6 个) | 6h | 数据库迁移、文档编写、安全审计、性能优化、UI 实现、熵清理 |
| 2.10 | Skills 设计指南 | `guides/skills-design.md` | 3h | 如何设计、测试、迭代 Skill |
| **架构约束** |
| 2.11 | 分层依赖规则模板 | `templates/constraints/layer-rules.md` | 3h | 参考 OpenAI: Types → Config → Repo → Service → Runtime → UI |
| 2.12 | Agent 友好错误消息设计指南 | `templates/constraints/error-message-design.md` | 3h | 错误 + 位置 + 上下文 + 修复建议 + 参考模式 + 验证命令 |
| 2.13 | ESLint 自定义规则示例 | `templates/constraints/examples/eslint-custom/` | 5h | 分层依赖检查 + 文件长度限制 + Agent 友好格式化器 |
| 2.14 | 结构测试示例 | `templates/constraints/examples/structural-tests/` | 4h | TypeScript + Python 架构边界测试 |
| **评分工具** |
| 2.15 | Harness 成熟度 Checklist（纸质版） | `tools/harness-score/checklist.md` | 2h | 8 层 × 评分项，人工可用 |
| 2.16 | 评分维度 YAML 定义 | `tools/harness-score/dimensions.yaml` | 2h | 机器可读的评分维度 |
| **平台适配** |
| 2.17 | 平台适配概述 + 对照表 | `templates/platform-adapters/README.md` + `guides/platform-comparison.md` | 3h | Claude Code / Cursor / Copilot / Codex 对比 |
| 2.18 | 各平台模板文件 | `templates/platform-adapters/*/` | 4h | 4 平台各一个模板 |

---

### Phase 3：工具 + 熵管理 + CI（第 4-5 周）

**目标**：可执行工具 MVP + 熵管理体系 + CI 自动化

**交付标准**：运行 `python tools/harness-score/scorer.py /path/to/project` 输出成熟度报告

| # | 任务 | 产出文件 | 工时 | 详细说明 |
|---|------|---------|------|---------|
| **评分工具** |
| 3.1 | harness-score 评分引擎 MVP | `tools/harness-score/scorer.py` | 8h | 扫描项目目录，检测各层组件存在性，输出评分 |
| 3.2 | 评分报告模板 | `tools/harness-score/report-template.md` | 2h | 包含分数 + 各层详情 + 改进建议 |
| **初始化工具** |
| 3.3 | harness-init 交互式初始化 | `tools/harness-init/init.py` | 6h | 问答式选择 → 生成对应模板文件到目标项目 |
| 3.4 | 预设配置 | `tools/harness-init/presets/` (3 个) | 3h | 极简/标准/企业级三档预设 |
| **熵管理** |
| 3.5 | 清理 Agent Prompt 模板 | `templates/entropy/cleanup-agent-prompt.md` | 3h | 参考 OpenAI "Golden principles + 自动修复 PR" |
| 3.6 | 文档园丁 Agent Prompt | `templates/entropy/doc-gardener-prompt.md` | 3h | 检测文档漂移，生成更新 PR |
| 3.7 | 黄金原则模板 | `templates/entropy/golden-principles.md` | 2h | 不可违反的核心原则清单 |
| 3.8 | 每周熵审计清单 | `templates/entropy/weekly-entropy-review.md` | 2h | 团队周会可用的检查项 |
| 3.9 | 熵累积反模式 | `templates/entropy/anti-patterns.md` | 2h | 常见退化模式 + 预防措施 |
| **熵扫描器** |
| 3.10 | 熵扫描器核心引擎 | `tools/entropy-scanner/scan.py` | 6h | 插件架构，支持多种检测器 |
| 3.11 | 文档漂移检测器 | `tools/entropy-scanner/detectors/doc-drift.py` | 4h | 对比文档描述 vs 代码实现 |
| 3.12 | 规则冲突检测器 | `tools/entropy-scanner/detectors/rule-conflict.py` | 3h | 检测规则文件内/间的矛盾 |
| **CI 集成** |
| 3.13 | Harness 健康检查 Workflow | `ci/github-actions/harness-check.yml` | 3h | 每次 PR 检查 Harness 完整性 |
| 3.14 | 定期熵扫描 Workflow | `ci/github-actions/entropy-scan.yml` | 2h | 每周自动运行熵扫描 |
| 3.15 | 文档园丁 Workflow | `ci/github-actions/doc-gardener.yml` | 2h | 每周自动检测文档漂移 |
| 3.16 | Agent 代码审查 Workflow | `ci/github-actions/agent-code-review.yml` | 3h | PR 触发 Agent 代码审查 |
| **环境隔离** |
| 3.17 | Worktree 一键脚本 | `templates/environments/worktree-setup.sh` | 2h | 创建隔离的 git worktree + 端口分配 |
| 3.18 | 自动销毁脚本 | `templates/environments/teardown.sh` | 1h | 清理 worktree + 释放资源 |
| 3.19 | Devbox 配置指南 | `templates/environments/devbox-config.md` | 3h | 参考 Stripe: "cattle, not pets" |

---

### Phase 4：打磨 + 验证 + 发布（第 6-8 周）

**目标**：在至少 2 个真实项目验证，迭代到 V1.0，正式发布

| # | 任务 | 产出 | 工时 | 详细说明 |
|---|------|------|------|---------|
| 4.1 | 实践项目 A 全面应用 | 实践反馈文档 | 持续 | 记录每个模板的实际使用体验 |
| 4.2 | 实践项目 B 全面应用 | 实践反馈文档 | 持续 | 不同类型项目的交叉验证 |
| 4.3 | 根据实践反馈迭代模板 | V1.0 模板全套 | 10h | 所有模板经实战检验 |
| 4.4 | Linter 规则生成器 | `tools/linter-gen/generate.py` | 6h | 输入架构约束描述 → 输出 Linter 规则 |
| 4.5 | 完善 README.md V1.0 | README.md + README-zh.md | 4h | 含效果对比数据、快速开始、评分截图 |
| 4.6 | CONTRIBUTING.md | 贡献指南 | 2h | 如何贡献模板、工具、翻译 |
| 4.7 | Harness 反模式指南 | `guides/anti-patterns.md` | 3h | 研究发现的所有"别这样做" |
| 4.8 | 推理优化指南 | `guides/reasoning-optimization.md` | 3h | 推理三明治等策略 |
| 4.9 | 给老项目加装指南 | `guides/retrofitting.md` | 4h | Böckeler 的遗留代码警告 + 渐进式加装路径 |
| 4.10 | 正式发布 V1.0 | GitHub Release | 2h | Tag + Release Notes + 配合推广 |

---

## 五、关键文件详细内容规划

### 5.1 `guides/philosophy.md` 大纲

```
# Harness Engineering 哲学与方法论

## 1. 三代演进
- Prompt Engineering (2023-2024): "怎么跟 AI 说话"
- Context Engineering (2025): "给 AI 看什么信息"
- Harness Engineering (2026-): "构建什么环境让 AI 工作"

## 2. 核心公式
Agent = Model + Harness
"模型包含智能，Harness 让智能有用"

## 3. 马具隐喻
马（模型）提供动力，马具（Harness）确保动力被生产性地引导

## 4. 严谨性迁移
引用 Chad Fowler: "生成越容易，判断越严格"
- 手写代码 → 关注实现细节
- AI 生成代码 → 关注架构约束和验证

## 5. 概率思维（Böckeler 的"控制幻觉"警告）
- Harness 提高的是成功概率，不是保证
- 用概率而非确定性思维设计系统
- "尽管叫工程，执行仍依赖 LLM 的解读"

## 6. 反应式 vs 预设式
- Hashimoto: "每次看到 Agent 做坏事就阻止它再做"
- ETH Zurich: 预设的 LLM 生成规则降低性能 20%+
- 最佳实践：从观察开始，而非从假设开始

## 7. 约束悖论
- 更多约束 → 更大自主性（Böckeler 假设 2）
- 窄化搜索空间 → Agent 更快找到好解决方案
- "在人类优先的工作流中，这些规则可能显得迂腐。
   对 Agent 来说，它们变成乘数器。" — OpenAI

## 8. 模型是商品，Harness 是护城河
- 同一模型，不同 Harness → 40 分任务完成率差异
- Terminal Bench: 52.8% → 66.5%（仅改 Harness）
- 你的竞争优势在于环境设计，不在于选了哪个模型
```

### 5.2 `guides/anti-patterns.md` 大纲

```
# Harness 反模式指南

## 反模式 1：用 AI 生成 AI 的规则
ETH Zurich 研究发现 LLM 生成的 AGENTS.md 降低性能 20%+
✅ 正确做法：人工根据观察到的 Agent 错误编写

## 反模式 2：上下文过载
性能在 ~40% 上下文占用时开始下降（~168K token 窗口）
✅ 正确做法：渐进式披露，Skills 按需加载

## 反模式 3：预设万能配置
"以防万一"装几十个 Skills/MCP 服务器
✅ 正确做法：最小集合，按需添加

## 反模式 4：每次会话跑完整测试
等待时间过长，Agent 效率大幅下降
✅ 正确做法：关键路径快速测试 < 1 分钟，完整测试留给 CI

## 反模式 5：规则文件百科全书化
重要规则被噪音淹没，Agent 遵从率下降
✅ 正确做法：< 200 行，每条规则对应具体错误

## 反模式 6：无限重试 CI
Agent 陷入修复 → 失败 → 修复的无限循环
✅ 正确做法：Stripe 模式 — 最多 2 轮 CI，然后交给人

## 反模式 7：忽视熵管理
规则文件随时间累积矛盾，文档与实现漂移
✅ 正确做法：每周熵审计 + 清理 Agent 定期运行

## 反模式 8：Harness 与模型紧耦合
为某个模型过度优化，换模型后失效
✅ 正确做法：原则通用化，实现适配化
```

---

## 六、技术选型（v2.0 升级）

| 维度 | v1.0 选型 | v2.0 选型 | 变更理由 |
|------|----------|----------|---------|
| 模板格式 | Markdown | Markdown + YAML frontmatter | 增加机器可读元数据 |
| 工具语言 | Python | Python 3.11+ (ruff + mypy) | 明确版本和工具链 |
| Linter 示例 | ESLint + Ruff | ESLint + Ruff + Agent 友好格式化器 | 增加自定义格式化器 |
| CI 平台 | GitHub Actions | GitHub Actions + Agent 代码审查 | 增加 Agent 审查 workflow |
| 评分工具 | CLI + YAML | CLI + YAML + 纸质 Checklist | MVP 前先有手动版 |
| Hooks | 无 | Claude Code hooks + 通用中间件模式 | **最大新增** |
| Skills | 无 | 12 个整合 Skill 模板 | **关键性能杠杆** |
| 平台适配 | 无 | 4 平台适配模板 | 覆盖主流 Agent |

---

## 七、与其他工作线的协同（v2.0 更新）

| 协同关系 | 具体方式 | 触发时机 |
|---------|---------|---------|
| A → B（工具包 → 评估服务） | harness-score 的 8 层模型是评估服务核心 | Phase 3 评分工具完成后 |
| A → C（工具包 → 内容布道） | 每完成一个模板/工具，产出一篇文章 | 每个 Phase 完成时 |
| A ← D（工具包 ← 实践验证） | D 线实践反馈直接改进模板 | Phase 4 持续进行 |
| A → D（工具包 → 实践验证） | D 线用 harness-init 工具启动项目 | Phase 3 init 工具完成后 |
| **新增** A ← 研究（持续跟踪） | 持续跟踪新的研究和案例 | 每月更新 research/ |

---

## 八、风险与缓解（v2.0 升级）

| 风险 | 可能性 | 影响 | 缓解措施 | 触发指标 |
|------|--------|------|---------|---------|
| 概念太新，社区不认可 | 中 | 高 | C 线内容先培育认知 + D 线数据说话 | Star < 10 after 1 month |
| 模板太通用，用不上 | 中 | 高 | 每个模板必须附真实示例 + D 线实测 | 用户反馈"不知道怎么用" |
| 工具开发超时 | 中 | 中 | 先出纸质 Checklist（Phase 2.15），再做自动化 | Phase 3 延期 > 1 周 |
| agents.md 规范冲突 | 低 | 中 | 严格遵循规范，做增量 | 社区反馈"与标准不兼容" |
| **新增** Hooks 模板平台锁定 | 中 | 中 | 同时提供通用中间件模式文档 | 用户用非 Claude Code |
| **新增** 规则膨胀（自身的熵） | 中 | 高 | 项目自身做 dog-fooding + 定期精简 | 模板目录 > 100 文件 |
| **新增** 研究过时 | 高 | 低 | 研究文件标注日期 + 每月审视 | 新的重大论文/实践发布 |

---

## 九、成功标准

### 定量标准
- V1.0 发布后 1 个月：至少 2 个真实项目使用 harness-kit
- harness-init 工具：从 `python init.py` 到基础 Harness 搭建完成 < 5 分钟
- harness-score 工具：对任意项目生成评分报告 < 30 秒

### 定性标准
- 新手读完 getting-started.md 后，不需要额外指导就能搭建 Level 1-3 的 Harness
- 项目自身的 CLAUDE.md + AGENTS.md 被证明有效（dog-fooding）
- 至少收到 1 条社区反馈说 "这帮助我改进了 Agent 的工作质量"

---

## 十、立即可执行的下一步

```
1. ✅ 确认 GitHub 用户名（用于创建仓库）
2. 执行 Phase 0 全部任务（预计 2-3 小时）
   - 创建仓库 + 初始化结构
   - 编写项目自身的 CLAUDE.md 和 AGENTS.md
   - 搬入研究资料
   - 编写初版 README.md
3. 开始 Phase 1.4（错误驱动编写法指南）— 这是最核心的思想输出
4. 同步开始 Phase 1.2（AGENTS.md 标准模板）
```

---

## 附录：各 Phase 工时汇总

| Phase | 任务数 | 预估工时 | 累计 |
|-------|--------|---------|------|
| Phase 0 | 5 | 4h | 4h |
| Phase 1 | 8 | 23h | 27h |
| Phase 2 | 18 | 64h | 91h |
| Phase 3 | 19 | 56h | 147h |
| Phase 4 | 10 | 34h | 181h |
| **合计** | **60** | **~181h** | |

按每天 4 小时有效 Agent 协作时间计算，约需 **45 个工作日（~9 周）** 完成全部 Phase。

---

*计划版本 v2.0 | 2026-03-23 | 基于 4 份深度研究报告升级*
