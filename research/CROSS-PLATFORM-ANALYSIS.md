# harness-kit 跨平台 Harness 架构深度分析

> 核心问题：AGENTS.md 是否只有 Codex 认识？如果基于 Claude Code + Kiro，应该用什么形式？
> 多工具场景下的 Harness 架构该如何设计？

---

## 一、各平台规则文件全景对照

### 1.1 指令文件对照

| 能力维度 | Claude Code | Kiro (AWS) | Cursor | GitHub Copilot | OpenAI Codex |
|---------|------------|------------|--------|---------------|-------------|
| **主规则文件** | `CLAUDE.md` | `.kiro/steering/*.md` | `.cursor/rules/*.md` | `.github/copilot-instructions.md` | `AGENTS.md` |
| **识别 AGENTS.md** | 否（原生不识别） | **是**（自动识别） | **是**（作为替代方案） | **是**（作为 agent 指令） | **是**（原生格式） |
| **全局规则** | `~/.claude/CLAUDE.md` | `~/.kiro/steering/` | User Rules (设置面板) | Personal Instructions | 无 |
| **项目规则** | `./CLAUDE.md` | `.kiro/steering/` | `.cursor/rules/` | `.github/copilot-instructions.md` | `./AGENTS.md` |
| **路径特定规则** | `.claude/rules/` + YAML paths | fileMatch 模式 | glob 模式 | `.github/instructions/NAME.instructions.md` + applyTo | 子目录 AGENTS.md |
| **嵌套/继承** | 子目录 CLAUDE.md 覆盖父级 | workspace > global | Team > Project > User | personal > repo > org | 最近文件优先 |
| **按需加载** | Skills (`/skill-name`) | `inclusion: manual` (#引用) | @规则名 手动触发 | 无 | 无 |
| **智能加载** | Skills (模型判断) | `inclusion: auto` (描述匹配) | "Apply Intelligently" | 无 | 无 |
| **文件引用** | `@path/to/import` | `#[[file:path]]` | 引用文件路径 | 无 | 无 |

### 1.2 Hooks/中间件对照

| 能力维度 | Claude Code | Kiro (AWS) | Cursor | GitHub Copilot | OpenAI Codex |
|---------|------------|------------|--------|---------------|-------------|
| **Hooks 系统** | settings.json hooks | Kiro Hook UI | 无原生 hooks | 无 | 沙箱权限 |
| **生命周期事件** | 24+ (SessionStart, PreToolUse, PostToolUse, Stop 等) | 文件操作、Agent交互、工具调用、任务执行、手动触发 | 无 | 无 | 无 |
| **处理器类型** | 4 种（Command, HTTP, Prompt, Agent） | 2 种（Agent Prompt, Shell Command） | 无 | 无 | 无 |
| **确定性执行** | 是（shell 脚本硬执行） | 是（shell 命令） | 否 | 否 | 沙箱约束 |

### 1.3 上下文管理对照

| 能力维度 | Claude Code | Kiro (AWS) | Cursor | GitHub Copilot | OpenAI Codex |
|---------|------------|------------|--------|---------------|-------------|
| **渐进式披露** | Skills（按需加载） | inclusion: auto/manual | Apply Intelligently | 无 | 无 |
| **上下文压缩** | /compact + 自动压缩 | 无明确机制 | 内置管理 | 内置管理 | 云端管理 |
| **子 Agent** | 支持（独立上下文窗口） | 无明确支持 | 无 | 无 | 并行 Agent |
| **MCP 支持** | 完整支持 | 支持 | 支持 | 无 | 无 |

### 1.4 特有能力

| 平台 | 独特优势 |
|------|---------|
| **Claude Code** | 最完整的 Hooks 体系（24+ 事件 × 4 种处理器）、Skills 渐进式披露、子 Agent 隔离、auto-memory |
| **Kiro** | **Specs 系统**（需求 → 设计 → 任务三阶段结构化开发）、Steering 四种加载模式、与 AWS 生态深度集成 |
| **Cursor** | IDE 内嵌体验、Remote Import（从 GitHub 导入规则）、Team Rules 仪表盘 |
| **Copilot** | GitHub 生态集成、PR/Issue 上下文、多 Agent 角色排除（excludeAgent） |
| **Codex** | 云端沙箱执行、长时间运行（6 小时+）、并行 Agent |

---

## 二、关键发现：AGENTS.md 的跨平台地位

### AGENTS.md 不是 Codex 独占的

根据研究，AGENTS.md 的识别情况如下：

| 平台 | 是否识别 AGENTS.md | 方式 |
|------|-------------------|------|
| OpenAI Codex | **原生格式** | 主要指令文件 |
| Kiro | **自动识别** | "Place files in ~/.kiro/steering/ or workspace root—they're automatically picked up" |
| Cursor | **支持** | 作为 "simpler alternative" 在文档中推荐 |
| GitHub Copilot | **识别** | 作为 agent instruction files，与 CLAUDE.md/GEMINI.md 同级 |
| Claude Code | **不原生识别** | 需要在 CLAUDE.md 中 `@AGENTS.md` 导入 |

**结论**：AGENTS.md 已成为事实上的**跨平台通用标准**，4/5 主流工具原生识别。唯一例外是 Claude Code，但可通过 `@` 导入机制间接支持。

### 但 AGENTS.md 有局限

| 局限 | 影响 |
|------|------|
| 不支持加载模式（always/auto/manual/fileMatch） | 无法实现渐进式披露 |
| 不支持 Hooks | 无法做确定性执行 |
| 不支持 Skills | 无法按需加载专业知识 |
| 无法表达平台特定配置 | Hooks、权限、MCP 等配置需要平台原生格式 |

**AGENTS.md 适合表达"是什么"和"该怎么做"，不适合表达"如何强制执行"和"何时加载"。**

---

## 三、推荐架构：三层 Harness 模型

基于以上分析，harness-kit 应该采用**三层架构**：

```
┌─────────────────────────────────────────────────┐
│  Layer 3: Platform Features（平台特有能力）       │
│  Claude Code: Skills, Hooks, SubAgents           │
│  Kiro: Specs (需求→设计→任务), Auto-Steering      │
│  Cursor: Team Rules, Remote Import               │
│  仅在使用特定平台时才需要                          │
├─────────────────────────────────────────────────┤
│  Layer 2: Platform Adapter（平台适配层）          │
│  将通用规则转化为各平台原生格式                     │
│  CLAUDE.md / .kiro/steering/ / .cursor/rules/    │
│  同一套规则内容，不同的文件格式和元数据             │
├─────────────────────────────────────────────────┤
│  Layer 1: Universal Content（通用内容层）         │
│  AGENTS.md — 跨平台通用，4/5 工具原生识别          │
│  包含：项目概述、命令、架构、约束、验证方式          │
│  这是你的 Harness 的"单一事实来源"                 │
└─────────────────────────────────────────────────┘
```

### 3.1 Layer 1：通用内容层（AGENTS.md）

**角色**：Harness 的"宪法"，跨平台的单一事实来源

```markdown
# AGENTS.md（通用层示例）

## 项目概述
这是一个 Next.js 14 Web 应用...

## 开发命令
- 启动开发服务器: `npm run dev`
- 运行测试: `npm test`（<1 分钟完成）
- 类型检查: `npx tsc --noEmit`
- Lint: `npm run lint`

## 架构约束
- 分层依赖: UI → Service → Repository → Types
- 每个文件不超过 300 行
- 所有 API 端点必须有输入验证

## 已知的 Agent 常见错误（错误驱动）
- 不要用 `yarn`，本项目用 `npm`
- 测试文件放在 `__tests__/` 而非 `*.test.ts`
- 不要修改 `src/core/` 下的文件，这是受保护的核心

## 验证清单
修改代码后，必须通过:
1. `npm run lint`
2. `npm test`
3. `npx tsc --noEmit`
```

**所有工具（Codex, Kiro, Cursor, Copilot）都能直接读取这份文件。**

### 3.2 Layer 2：平台适配层

将 Layer 1 的通用内容适配为各平台原生格式，并添加平台特定元数据。

**Claude Code 适配 (`CLAUDE.md`)**：
```markdown
# CLAUDE.md

## 导入通用规则
@AGENTS.md

## Claude Code 特有配置
- 使用 Sonnet 做日常任务，Opus 做架构决策
- 压缩时保留完整的修改文件列表
- 禁止使用 git push，所有推送需人工确认
```

**Kiro 适配 (`.kiro/steering/project.md`)**：
```yaml
---
inclusion: always
---
# 项目约定

（内容与 AGENTS.md 一致，但用 Kiro 的 steering 格式包装）

参考项目根目录的 AGENTS.md 获取完整规则。
```

**Kiro 路径特定规则 (`.kiro/steering/api-rules.md`)**：
```yaml
---
inclusion: fileMatch
fileMatchPattern: "src/api/**/*"
---
# API 开发规则
- 所有端点使用 zod 进行输入验证
- 错误响应遵循 RFC 7807 格式
```

**Cursor 适配 (`.cursor/rules/project.md`)**：
```yaml
---
description: "项目核心约定和架构规则"
alwaysApply: true
---
（内容引用 AGENTS.md）
```

### 3.3 Layer 3：平台特有能力层

这一层是各平台**独有的差异化功能**，无法跨平台复用：

**Claude Code 独有**：
```
.claude/
├── rules/
│   ├── api-rules.md              # 路径特定规则（paths: ["src/api/**"]）
│   └── test-rules.md
├── skills/
│   ├── code-review/SKILL.md      # 代码审查 Skill
│   ├── debugging/SKILL.md        # 调试 Skill
│   └── refactoring/SKILL.md      # 重构 Skill
└── settings.json                  # Hooks 配置
    hooks:
      PostToolUse: [auto-lint]
      Stop: [require-tests-pass]
```

**Kiro 独有**：
```
.kiro/
├── steering/
│   ├── product.md                # 产品定位（inclusion: always）
│   ├── tech.md                   # 技术栈（inclusion: always）
│   ├── structure.md              # 目录结构（inclusion: always）
│   ├── api-design.md             # API 设计（inclusion: auto）
│   └── debugging-guide.md        # 调试指南（inclusion: manual）
├── specs/                        # Specs 系统（Kiro 核心差异化）
│   └── feature-xxx/
│       ├── requirements.md
│       ├── design.md
│       └── tasks.md
└── hooks/                        # Kiro Hooks
    ├── on-file-save-lint          # 保存时自动 lint
    └── after-task-test            # 任务完成后运行测试
```

---

## 四、Claude Code + Kiro 双工具协作方案

如果你同时使用 Claude Code 和 Kiro，推荐以下文件布局：

```
my-project/
├── AGENTS.md                     # Layer 1: 通用规则（双方都能读取）
│                                 #   Kiro: 自动识别
│                                 #   Claude Code: 通过 CLAUDE.md @导入
│
├── CLAUDE.md                     # Layer 2: Claude Code 适配
│   # @AGENTS.md                  #   导入通用规则
│   # + Claude Code 特有配置      #   压缩策略、模型选择、推送权限等
│
├── .claude/                      # Layer 3: Claude Code 特有能力
│   ├── rules/                    #   路径特定规则
│   ├── skills/                   #   渐进式披露 Skills
│   └── settings.json             #   Hooks 配置
│
├── .kiro/                        # Layer 3: Kiro 特有能力
│   ├── steering/                 #   Kiro 指导文件
│   │   ├── product.md            #     产品定位
│   │   ├── tech.md               #     技术栈
│   │   ├── structure.md          #     目录结构
│   │   └── api-design.md         #     API 设计（auto 模式）
│   ├── specs/                    #   Kiro Specs（需求→设计→任务）
│   └── hooks/                    #   Kiro Hooks
│
├── .cursor/                      # Layer 3: 如果也用 Cursor
│   └── rules/
│
└── .github/                      # Layer 3: 如果也用 Copilot
    └── copilot-instructions.md
```

**工作流分工建议**：

| 场景 | 推荐工具 | 原因 |
|------|---------|------|
| 复杂多文件重构 | Claude Code | 子 Agent 隔离 + Hooks 验证门 |
| 新功能结构化开发 | Kiro | Specs 系统（需求→设计→任务）天然适合 |
| 快速修 bug | Claude Code 或 Kiro | 都可以，Claude Code 有 /investigate |
| 代码审查 | Claude Code | 多 Agent 并行审查能力 |
| 文档编写 | Kiro | Steering 的 auto 模式自动匹配上下文 |
| 长时间后台任务 | Claude Code | 后台 Agent + Ralph Loop 支持 |

---

## 五、harness-kit 模板目录结构更新建议

基于以上分析，建议将 v2.0 的 `templates/` 结构重构为三层架构：

```
templates/
├── universal/                        # ===== Layer 1: 跨平台通用 =====
│   ├── agents-md/                    # AGENTS.md 模板（所有工具通用）
│   │   ├── minimal.md               # 极简版（5-10行）
│   │   ├── standard.md              # 标准版（~100行）
│   │   ├── monorepo.md              # 单仓版
│   │   ├── writing-guide.md         # 错误驱动编写法
│   │   └── examples/                # 按项目类型的示例
│   │       ├── web-app.md
│   │       ├── api-service.md
│   │       ├── data-pipeline.md
│   │       ├── mobile-app.md
│   │       ├── cli-tool.md
│   │       └── ml-project.md
│   │
│   ├── knowledge-base/              # 知识库结构（跨平台通用）
│   │   ├── docs/
│   │   │   ├── ARCHITECTURE.md
│   │   │   ├── QUALITY.md
│   │   │   ├── BELIEFS.md
│   │   │   ├── TECH-DEBT.md
│   │   │   ├── designs/TEMPLATE.md
│   │   │   └── plans/PLANS.md
│   │   └── README.md
│   │
│   ├── constraints/                  # 架构约束（通用概念）
│   │   ├── layer-rules.md
│   │   ├── error-message-design.md
│   │   └── examples/
│   │       ├── eslint-custom/
│   │       ├── ruff-custom/
│   │       └── structural-tests/
│   │
│   └── entropy/                      # 熵管理（通用概念）
│       ├── golden-principles.md
│       ├── quality-grades.md
│       ├── weekly-entropy-review.md
│       └── anti-patterns.md
│
├── adapters/                         # ===== Layer 2: 平台适配 =====
│   ├── README.md                     # 平台对照表 + 选择指南
│   ├── claude-code/
│   │   └── CLAUDE.md.template        # 含 @AGENTS.md 导入
│   ├── kiro/
│   │   ├── product.md.template       # Kiro steering 三件套
│   │   ├── tech.md.template
│   │   └── structure.md.template
│   ├── cursor/
│   │   └── project-rules.md.template # .cursor/rules/ 格式
│   └── copilot/
│       └── copilot-instructions.md.template
│
├── platform-features/                # ===== Layer 3: 平台特有能力 =====
│   ├── claude-code/
│   │   ├── hooks/                    # Hooks 模板（Claude Code 独有）
│   │   │   ├── settings-hooks.json
│   │   │   ├── pre-tool-use/
│   │   │   ├── post-tool-use/
│   │   │   └── stop/
│   │   ├── skills/                   # Skills 模板（Claude Code 独有）
│   │   │   ├── code-review/SKILL.md
│   │   │   ├── debugging/SKILL.md
│   │   │   ├── refactoring/SKILL.md
│   │   │   └── ... (12 个)
│   │   └── rules/                    # 路径特定规则模板
│   │       ├── api-rules.md
│   │       └── test-rules.md
│   │
│   ├── kiro/
│   │   ├── steering/                 # Kiro Steering 高级模板
│   │   │   ├── api-design.md         # inclusion: auto
│   │   │   ├── testing-patterns.md   # inclusion: auto
│   │   │   └── debugging-guide.md    # inclusion: manual
│   │   ├── specs/                    # Kiro Specs 模板（Kiro 独有）
│   │   │   ├── feature-spec/
│   │   │   │   ├── requirements.md.template
│   │   │   │   ├── design.md.template
│   │   │   │   └── tasks.md.template
│   │   │   └── bugfix-spec/
│   │   │       └── bugfix.md.template
│   │   └── hooks/                    # Kiro Hooks 模板
│   │       ├── on-save-lint.md
│   │       └── after-task-test.md
│   │
│   └── cursor/
│       ├── rules/                    # Cursor 高级规则
│       │   ├── auto-rules/           # Apply Intelligently 规则
│       │   └── file-scoped/          # glob 模式文件规则
│       └── remote-imports.md         # Remote Import 指南
│
├── combos/                           # ===== 多工具组合方案 =====
│   ├── README.md                     # 组合策略总览
│   ├── claude-plus-kiro/             # Claude Code + Kiro 双工具方案
│   │   ├── layout.md                 # 推荐目录布局
│   │   ├── workflow.md               # 工作流分工建议
│   │   └── scaffold/                 # 一键生成的脚手架
│   │       ├── AGENTS.md
│   │       ├── CLAUDE.md
│   │       └── .kiro/steering/
│   ├── claude-plus-cursor/           # Claude Code + Cursor 方案
│   ├── full-stack/                   # 全工具方案
│   └── migration/                    # 工具迁移指南
│       ├── cursor-to-claude.md
│       ├── copilot-to-kiro.md
│       └── codex-to-claude.md
│
└── environments/                     # 环境隔离（跨平台通用）
    ├── worktree-setup.sh
    ├── teardown.sh
    ├── docker-compose.yml
    └── devbox-config.md
```

---

## 六、核心设计原则

### 原则 1：内容与格式分离

```
通用内容（AGENTS.md）  ──适配──→  平台格式（CLAUDE.md / .kiro/steering/ / .cursor/rules/）
      ↑                                    ↑
  写一次                              自动/手动生成
  维护一处                            多平台同步
```

### 原则 2：AGENTS.md 是"宪法"，平台文件是"实施细则"

- AGENTS.md 定义**做什么**和**为什么**
- 平台文件定义**怎么执行**和**何时加载**
- 如果两者冲突，以 AGENTS.md 为准

### 原则 3：平台能力是增强，不是替代

```
基线效果（仅 AGENTS.md）：         ████████░░  ~60%
+ Claude Code Hooks + Skills：     █████████░  ~85%
+ Kiro Specs + Auto-Steering：     █████████░  ~85%
+ 双工具协作 + 完整 Harness：      ██████████  ~95%
```

### 原则 4：渐进式加载的通用语义

不同平台实现"渐进式加载"的方式不同，但语义等价：

| 语义 | Claude Code | Kiro | Cursor |
|------|------------|------|--------|
| 始终加载 | CLAUDE.md | `inclusion: always` | `alwaysApply: true` |
| 路径匹配时加载 | `.claude/rules/` + paths | `inclusion: fileMatch` | `globs: [...]` |
| AI 判断时加载 | Skills (模型推断) | `inclusion: auto` | "Apply Intelligently" |
| 手动加载 | `/skill-name` | `#steering-name` | `@rule-name` |

**harness-kit 应该用统一的语义标记模板，然后生成各平台对应的格式。**

---

## 七、对 harness-init 工具的影响

初始化工具需要支持以下交互流程：

```
$ python tools/harness-init/init.py

🔧 harness-kit 初始化向导

1. 你使用哪些 AI 编码工具？（可多选）
   [x] Claude Code
   [x] Kiro
   [ ] Cursor
   [ ] GitHub Copilot
   [ ] OpenAI Codex

2. 项目类型？
   [x] Web 应用 (Next.js)

3. Harness 级别？
   [ ] Level 1: 仅规则文件
   [x] Level 2: 规则 + 约束 + 验证
   [ ] Level 3: 完整 Harness

生成中...

✅ 已生成以下文件：
   AGENTS.md                    (通用层 - 双工具共享)
   CLAUDE.md                    (Claude Code 适配)
   .claude/rules/api-rules.md   (Claude Code 路径规则)
   .claude/settings.json         (Claude Code Hooks)
   .kiro/steering/product.md    (Kiro steering)
   .kiro/steering/tech.md       (Kiro steering)
   .kiro/steering/structure.md  (Kiro steering)

📖 下一步：阅读 AGENTS.md，根据你观察到的 Agent 错误逐步完善内容
```

---

*分析版本 v1.0 | 2026-03-23 | 基于 Claude Code、Kiro、Cursor、Copilot、Codex 五大平台实际文档*
