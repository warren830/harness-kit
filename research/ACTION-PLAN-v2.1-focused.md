# harness-kit 行动计划 v2.1（聚焦版）

> **范围决策**：v1.0 仅支持 Claude Code + Kiro，其他平台后续扩展
> 2026-03-23

---

## 一、范围收敛理由

| 决策 | 理由 |
|------|------|
| 先支持 Claude Code | Harness 能力最完整（Hooks 24+ 事件、Skills、子 Agent、MCP） |
| 先支持 Kiro | Specs 系统是独特差异化能力，与 Claude Code 互补性最强 |
| 暂不支持 Cursor/Copilot/Codex | 避免过早抽象，等核心模板经实战验证后再扩展 |
| AGENTS.md 保留为通用层 | Kiro 原生识别 + Claude Code 通过 `@` 导入，天然的共享桥梁 |

### 双工具互补矩阵

```
Claude Code 擅长            Kiro 擅长
────────────────           ────────────────
复杂多文件重构               结构化新功能开发（Specs）
Hooks 确定性验证门           四种 Steering 加载模式
Skills 渐进式披露            文件匹配自动加载上下文
子 Agent 并行隔离            需求→设计→任务三阶段
后台长时间运行               与 AWS 生态集成
代码审查（多 Agent）          产品/技术/结构三维指导
```

---

## 二、精简后的仓库结构

```
harness-kit/
├── README.md                          # 项目介绍 + 快速开始
├── README-zh.md                       # 中文版
├── LICENSE                            # MIT
├── CLAUDE.md                          # 本项目自身的 Claude Code 配置（dog-fooding）
├── AGENTS.md                          # 本项目自身的通用规则（dog-fooding）
├── .kiro/                             # 本项目自身的 Kiro 配置（dog-fooding）
│   └── steering/
│       ├── product.md
│       ├── tech.md
│       └── structure.md
│
├── templates/                         # ===== 核心模板 =====
│   │
│   ├── universal/                     # Layer 1: 跨平台通用（AGENTS.md）
│   │   ├── agents-md/
│   │   │   ├── minimal.md            # 极简版（5-10 行）
│   │   │   ├── standard.md           # 标准版（~100 行）
│   │   │   ├── monorepo.md           # 单仓版
│   │   │   └── writing-guide.md      # 错误驱动编写法
│   │   │
│   │   ├── knowledge-base/           # 知识库结构
│   │   │   └── docs/
│   │   │       ├── ARCHITECTURE.md
│   │   │       ├── QUALITY.md
│   │   │       ├── BELIEFS.md
│   │   │       ├── TECH-DEBT.md
│   │   │       └── plans/PLANS.md
│   │   │
│   │   ├── constraints/              # 架构约束
│   │   │   ├── layer-rules.md
│   │   │   ├── error-message-design.md
│   │   │   └── examples/
│   │   │       ├── eslint-agent-friendly/
│   │   │       └── structural-tests/
│   │   │
│   │   └── entropy/                  # 熵管理
│   │       ├── golden-principles.md
│   │       ├── quality-grades.md
│   │       └── weekly-review.md
│   │
│   ├── claude-code/                   # Layer 2+3: Claude Code 专属
│   │   ├── CLAUDE.md.template         # 适配模板（含 @AGENTS.md 导入）
│   │   ├── rules/                     # .claude/rules/ 路径特定规则
│   │   │   ├── api-rules.md
│   │   │   ├── test-rules.md
│   │   │   └── ui-rules.md
│   │   ├── skills/                    # .claude/skills/ 渐进式披露
│   │   │   ├── README.md             # Skills 设计原则
│   │   │   ├── code-review.md
│   │   │   ├── debugging.md
│   │   │   ├── refactoring.md
│   │   │   ├── test-writing.md
│   │   │   ├── api-design.md
│   │   │   ├── ci-fix.md
│   │   │   ├── security-audit.md
│   │   │   ├── performance-opt.md
│   │   │   ├── doc-writing.md
│   │   │   ├── database-migration.md
│   │   │   ├── ui-implementation.md
│   │   │   └── entropy-cleanup.md
│   │   └── hooks/                     # settings.json Hooks 模板
│   │       ├── README.md
│   │       ├── settings-hooks.json    # 完整 Hooks 配置模板
│   │       ├── pre-tool-use/
│   │       │   ├── block-destructive.sh
│   │       │   └── restrict-paths.sh
│   │       ├── post-tool-use/
│   │       │   ├── auto-lint.sh
│   │       │   └── auto-format.sh
│   │       └── stop/
│   │           ├── require-tests.sh
│   │           └── require-lint.sh
│   │
│   ├── kiro/                          # Layer 2+3: Kiro 专属
│   │   ├── steering/                  # .kiro/steering/ 模板
│   │   │   ├── README.md             # Kiro Steering 使用指南
│   │   │   ├── product.md.template    # inclusion: always
│   │   │   ├── tech.md.template       # inclusion: always
│   │   │   ├── structure.md.template  # inclusion: always
│   │   │   ├── api-design.md         # inclusion: auto
│   │   │   ├── testing-patterns.md   # inclusion: auto
│   │   │   └── debugging-guide.md    # inclusion: manual
│   │   ├── specs/                     # .kiro/specs/ 模板
│   │   │   ├── README.md             # Specs 使用指南
│   │   │   ├── feature/
│   │   │   │   ├── requirements.md.template
│   │   │   │   ├── design.md.template
│   │   │   │   └── tasks.md.template
│   │   │   └── bugfix/
│   │   │       └── bugfix.md.template
│   │   └── hooks/                     # Kiro Hooks 模板
│   │       ├── on-save-lint.md
│   │       └── after-task-test.md
│   │
│   ├── combo/                         # 双工具协作方案
│   │   ├── README.md                  # Claude Code + Kiro 协作指南
│   │   ├── workflow.md                # 工作流分工建议
│   │   └── scaffold/                  # 一键脚手架
│   │       ├── AGENTS.md              # 通用层示例
│   │       ├── CLAUDE.md              # Claude Code 层示例
│   │       └── .kiro/steering/        # Kiro 层示例
│   │
│   └── environments/                  # 环境隔离
│       ├── worktree-setup.sh
│       ├── teardown.sh
│       └── docker-compose.yml
│
├── tools/                             # ===== 工具 =====
│   ├── harness-init/                  # 一键初始化
│   │   ├── README.md
│   │   ├── init.py
│   │   └── presets/
│   │       ├── claude-only.yaml
│   │       ├── kiro-only.yaml
│   │       └── claude-plus-kiro.yaml  # 默认推荐
│   │
│   ├── harness-score/                 # 成熟度评分
│   │   ├── README.md
│   │   ├── scorer.py
│   │   ├── dimensions.yaml
│   │   └── checklist.md              # 手动版 checklist
│   │
│   └── entropy-scanner/               # 熵扫描器
│       ├── scan.py
│       └── detectors/
│           ├── doc-drift.py
│           └── rule-conflict.py
│
├── guides/                            # ===== 指南 =====
│   ├── getting-started.md             # 5 分钟快速开始
│   ├── getting-started-zh.md          # 中文版
│   ├── error-driven-writing.md        # 错误驱动编写法（核心方法论）
│   ├── philosophy.md                  # 方法论与哲学
│   ├── claude-code-harness.md         # Claude Code Harness 完全指南
│   ├── kiro-harness.md                # Kiro Harness 完全指南
│   ├── dual-tool-workflow.md          # 双工具协作工作流
│   ├── anti-patterns.md               # 反模式指南
│   └── retrofitting.md                # 老项目加装指南
│
├── ci/                                # ===== CI =====
│   └── github-actions/
│       ├── harness-check.yml
│       └── entropy-scan.yml
│
└── research/                          # ===== 调研（已完成） =====
    ├── harness-engineering-research.md
    ├── research-01~04 (英文+中文)
    └── CROSS-PLATFORM-ANALYSIS.md
```

### v2.0 → v2.1 精简对比

| 维度 | v2.0 | v2.1 | 减少 |
|------|------|------|------|
| 支持平台 | 5 个 | 2 个 | -60% |
| templates/ 子目录 | 8 个 | 6 个 | -25% |
| 平台适配文件 | 16+ | 6 | -62% |
| guides/ 文件 | 12 | 9 | -25% |
| 总任务数 | 60 | 42 | -30% |
| 预估工时 | ~181h | ~120h | -34% |

---

## 三、精简后的分阶段执行计划

### Phase 0：项目初始化 + Dog-Fooding（第 0 天，~4h）

| # | 任务 | 产出 | 工时 |
|---|------|------|------|
| 0.1 | 创建 GitHub 仓库 + 基础文件 | 仓库 + LICENSE + .gitignore | 0.5h |
| 0.2 | 编写本项目 AGENTS.md | `/AGENTS.md` — 通用规则 | 1h |
| 0.3 | 编写本项目 CLAUDE.md | `/CLAUDE.md` — Claude Code 配置 | 1h |
| 0.4 | 编写本项目 .kiro/steering/ | `.kiro/steering/` 三件套 | 1h |
| 0.5 | 搬入研究资料 + 初版 README | `/research/` + `README.md` | 0.5h |

**验收**：用 Claude Code 和 Kiro 分别打开项目，两者都能正确读取规则并遵循。

---

### Phase 1：核心通用层（第 1 周，~20h）

**目标**：AGENTS.md 模板体系 + 知识库 + 核心方法论

| # | 任务 | 产出 | 工时 | 优先级 |
|---|------|------|------|--------|
| 1.1 | AGENTS.md 极简模板 | `templates/universal/agents-md/minimal.md` | 1h | P0 |
| 1.2 | AGENTS.md 标准模板 | `templates/universal/agents-md/standard.md` | 3h | P0 |
| 1.3 | AGENTS.md 单仓模板 | `templates/universal/agents-md/monorepo.md` | 2h | P1 |
| 1.4 | **错误驱动编写法指南** | `templates/universal/agents-md/writing-guide.md` + `guides/error-driven-writing.md` | 4h | **P0** |
| 1.5 | 知识库模板全套 | `templates/universal/knowledge-base/` | 3h | P1 |
| 1.6 | **快速开始指南** | `guides/getting-started.md` + `-zh.md` | 3h | **P0** |
| 1.7 | **方法论指南** | `guides/philosophy.md` | 4h | **P0** |

**Phase 1 交付标准**：
- 用户 clone 后，5 分钟内能给项目加上 AGENTS.md + 基础知识库
- 错误驱动编写法指南读完后，用户知道"怎么迭代完善规则文件"

---

### Phase 2：Claude Code 专属层（第 2-3 周，~35h）

**目标**：Hooks + Skills + 路径规则，释放 Claude Code 最大潜力

| # | 任务 | 产出 | 工时 | 说明 |
|---|------|------|------|------|
| **Hooks 体系** |
| 2.1 | Hooks 概述 + 配置模板 | `templates/claude-code/hooks/README.md` + `settings-hooks.json` | 3h | 4 种处理器类型说明 |
| 2.2 | PreToolUse 钩子 | `pre-tool-use/` (2 个脚本) | 2h | 阻止危险命令 + 限制路径 |
| 2.3 | PostToolUse 钩子 | `post-tool-use/` (2 个脚本) | 2h | 自动 lint + 自动格式化 |
| 2.4 | **Stop 验证门** | `stop/` (2 个脚本) | 2h | 必须通过测试/lint |
| 2.5 | Claude Code 完全指南 | `guides/claude-code-harness.md` | 4h | Hooks+Skills+Rules 全教程 |
| **Skills 体系** |
| 2.6 | Skills 设计原则 | `templates/claude-code/skills/README.md` | 2h | "12整合 > 20碎片" |
| 2.7 | 核心 Skills (6 个) | `skills/` 前 6 个 | 6h | 审查/调试/重构/测试/API/CI |
| 2.8 | 扩展 Skills (6 个) | `skills/` 后 6 个 | 6h | 迁移/文档/安全/性能/UI/熵 |
| **约束 + 适配** |
| 2.9 | CLAUDE.md 适配模板 | `templates/claude-code/CLAUDE.md.template` | 1h | 含 @AGENTS.md 导入 |
| 2.10 | 路径特定规则 | `templates/claude-code/rules/` (3 个) | 2h | API/测试/UI 规则 |
| 2.11 | Agent 友好错误消息设计 | `templates/universal/constraints/error-message-design.md` | 2h | 错误+位置+修复+参考 |
| 2.12 | ESLint Agent 友好示例 | `templates/universal/constraints/examples/eslint-agent-friendly/` | 3h | 自定义格式化器 |

**Phase 2 交付标准**：
- Claude Code 用户能快速配置完整的 Hooks → Skills → Rules 三层防护
- Stop 钩子确保 Agent 完成前必须通过测试

---

### Phase 3：Kiro 专属层 + 双工具协作（第 3-4 周，~28h）

**目标**：Kiro Steering/Specs 模板 + Claude Code + Kiro 协作方案

| # | 任务 | 产出 | 工时 | 说明 |
|---|------|------|------|------|
| **Kiro Steering** |
| 3.1 | Steering 使用指南 | `templates/kiro/steering/README.md` | 2h | 四种 inclusion 模式详解 |
| 3.2 | 三件套模板 | `product.md` + `tech.md` + `structure.md` 模板 | 3h | inclusion: always |
| 3.3 | Auto 模式模板 | `api-design.md` + `testing-patterns.md` | 2h | inclusion: auto |
| 3.4 | Manual 模式模板 | `debugging-guide.md` | 1h | inclusion: manual |
| **Kiro Specs** |
| 3.5 | Specs 使用指南 | `templates/kiro/specs/README.md` | 2h | 需求→设计→任务三阶段 |
| 3.6 | Feature Spec 模板 | `specs/feature/` (3 个文件) | 3h | requirements + design + tasks |
| 3.7 | Bugfix Spec 模板 | `specs/bugfix/bugfix.md.template` | 1h | 当前/预期/不变行为分析 |
| 3.8 | Kiro Hooks 模板 | `templates/kiro/hooks/` (2 个) | 1h | 保存时 lint + 任务后测试 |
| 3.9 | Kiro 完全指南 | `guides/kiro-harness.md` | 3h | Steering+Specs+Hooks 全教程 |
| **双工具协作** |
| 3.10 | 协作方案文档 | `templates/combo/README.md` + `workflow.md` | 3h | 分工矩阵 + 文件布局 |
| 3.11 | 一键脚手架 | `templates/combo/scaffold/` | 2h | AGENTS.md + CLAUDE.md + .kiro/ |
| 3.12 | 双工具工作流指南 | `guides/dual-tool-workflow.md` | 3h | 何时用哪个工具 + 实际案例 |
| 3.13 | 反模式指南 | `guides/anti-patterns.md` | 2h | 双工具场景的常见坑 |

**Phase 3 交付标准**：
- Kiro 用户能快速配置 Steering + Specs 完整体系
- 双工具用户有清晰的分工方案和一键脚手架

---

### Phase 4：工具 + CI + 发布（第 5-6 周，~33h）

| # | 任务 | 产出 | 工时 |
|---|------|------|------|
| **工具** |
| 4.1 | harness-init 初始化工具 | `tools/harness-init/` | 6h |
| 4.2 | 三档预设（claude-only / kiro-only / combo） | `presets/` | 2h |
| 4.3 | harness-score checklist（手动版） | `tools/harness-score/checklist.md` | 2h |
| 4.4 | harness-score 自动评分 MVP | `tools/harness-score/scorer.py` | 6h |
| 4.5 | entropy-scanner MVP | `tools/entropy-scanner/` | 6h |
| **熵管理 + CI** |
| 4.6 | 熵管理模板全套 | `templates/universal/entropy/` | 3h |
| 4.7 | 环境隔离脚本 | `templates/environments/` | 2h |
| 4.8 | GitHub Actions CI 模板 | `ci/github-actions/` (2 个) | 3h |
| **发布** |
| 4.9 | 老项目加装指南 | `guides/retrofitting.md` | 3h |

---

### Phase 5：验证 + 打磨 + V1.0（第 7-8 周）

| # | 任务 | 工时 |
|---|------|------|
| 5.1 | 实践项目 A 全面应用 + 反馈 | 持续 |
| 5.2 | 实践项目 B 全面应用 + 反馈 | 持续 |
| 5.3 | 根据反馈迭代全部模板 | 8h |
| 5.4 | 完善 README V1.0（含效果数据） | 3h |
| 5.5 | CONTRIBUTING.md | 1h |
| 5.6 | 正式发布 V1.0 | 1h |

---

## 四、Claude Code + Kiro 特有的协作价值

### 为什么这两个组合特别有价值

```
开发生命周期              推荐工具         原因
──────────────          ──────────       ─────────────────────
需求分析                 Kiro             Specs 的 requirements.md 天然适合
技术设计                 Kiro             Specs 的 design.md + steering auto 模式
实现编码                 Claude Code      Hooks 验证门 + Skills 专业知识
                        或 Kiro          Specs 的 tasks.md 逐个执行
代码审查                 Claude Code      多 Agent 并行审查
调试修复                 Claude Code      /investigate + 子 Agent 隔离
重构优化                 Claude Code      复杂多文件操作 + Stop 钩子
文档维护                 Kiro             Auto-steering 自动匹配文档上下文
熵管理/清理              Claude Code      后台 Agent + entropy-cleanup Skill
```

### 共享 AGENTS.md 的实际工作流

```
1. 开发者用 Kiro 的 Specs 系统规划新功能
   → .kiro/specs/feature-x/requirements.md
   → .kiro/specs/feature-x/design.md
   → .kiro/specs/feature-x/tasks.md

2. 开发者切到 Claude Code 执行实现
   → Claude Code 读取 AGENTS.md（@导入）了解项目约定
   → Hooks 确保每次编辑通过 lint
   → Stop 钩子确保提交前通过测试
   → Skills 按需加载专业知识

3. 发现 Agent 犯错 → 更新 AGENTS.md
   → 两个工具下次都能读到修正后的规则

4. 周期性用 Claude Code 运行熵清理
   → entropy-cleanup Skill 扫描文档漂移
   → 更新 AGENTS.md / .kiro/steering/ 保持同步
```

---

## 五、工时汇总

| Phase | 任务数 | 工时 | 累计 |
|-------|--------|------|------|
| Phase 0 | 5 | 4h | 4h |
| Phase 1 | 7 | 20h | 24h |
| Phase 2 | 12 | 35h | 59h |
| Phase 3 | 13 | 28h | 87h |
| Phase 4 | 9 | 33h | 120h |
| Phase 5 | 6 | 13h | 133h |
| **合计** | **52** | **~133h** | |

比 v2.0 减少 48 小时（-26%），任务减少 8 个（-13%）。

---

## 六、未来扩展路径

```
V1.0 (Claude Code + Kiro)
  │
  ├── V1.1: + Cursor 支持（.cursor/rules/ 适配）
  │
  ├── V1.2: + Copilot 支持（.github/copilot-instructions.md 适配）
  │
  ├── V1.3: + Codex 支持（云端沙箱场景）
  │
  └── V2.0: 通用适配器框架（插件式添加新平台）
```

每次扩展只需新增：
1. `templates/<platform>/` 目录
2. `guides/<platform>-harness.md` 指南
3. `tools/harness-init/presets/<platform>.yaml` 预设

通用层（AGENTS.md、知识库、约束、熵管理）**零修改**。

---

*计划版本 v2.1 | 2026-03-23 | 聚焦 Claude Code + Kiro*
