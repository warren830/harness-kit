devpace vs harness-kit 对比

┌──────────┬────────────────────────────────────┬─────────────────────────────────────────────────┐
│   维度   │            harness-kit             │                     devpace                     │
├──────────┼────────────────────────────────────┼─────────────────────────────────────────────────┤
│ 定位     │ 生成器 — 帮团队搭建 agent 约束系统 │ 运行时框架 — Claude Code 插件，全程管控开发节奏 │
├──────────┼────────────────────────────────────┼─────────────────────────────────────────────────┤
│ 交付形式 │ CLI 工具 + 模板文件                │ Claude Code Plugin（.claude-plugin/）           │
├──────────┼────────────────────────────────────┼─────────────────────────────────────────────────┤
│ 方法论   │ Error-driven writing               │ BizDevOps 全链路                                │
├──────────┼────────────────────────────────────┼─────────────────────────────────────────────────┤
│ 状态管理 │ 无（生成后不再介入）               │ .devpace/state.md 持续追踪                      │
├──────────┼────────────────────────────────────┼─────────────────────────────────────────────────┤
│ 测试     │ 基本的 ruff/mypy                   │ 17个静态验证器 + 集成测试 + LLM行为评估         │
└──────────┴────────────────────────────────────┴─────────────────────────────────────────────────┘

两者互补多于竞争 — harness-kit 是「脚手架」，devpace 是「运行时引擎」。但 devpace 有很多设计模式值得借鉴：

  ---
可借鉴的 Top 8 模式（按优先级排序）

1. 模板验证测试体系 (HIGH)

devpace 有 17 个 Python 静态验证器，确保模板结构完整性：
- frontmatter 字段合法性校验
- 跨文件引用可达性检查
- 命名规范（kebab-case）强制
- schema 合规性验证
- placeholder 格式统一（{{PLACEHOLDER}}）

harness-kit 现状：只有 ruff/mypy 检查 Python 代码，模板文件零测试。

建议：在 tests/ 下创建模板验证套件：
- 所有模板 YAML frontmatter 有效
- 所有 "When to use" / "When NOT to use" section 存在
- 内部链接可达
- 文件不超过 200 行（已有规则但无自动检查）

  ---
2. Skill 拆分：Procedure 文件模式 (HIGH)

devpace 把复杂 skill 拆成多个 procedure 文件，按状态路由加载：
pace-dev/
SKILL.md                      ← 入口（路由逻辑）
dev-procedures-intent.md      ← created 状态
dev-procedures-developing.md  ← developing 状态
dev-procedures-gate.md        ← verifying 状态

harness-kit 现状：每个 skill 是单一文件，复杂场景可能导致文件过长或覆盖不足。

建议：对 debugging.md、code-review.md 等复杂 skill 模板，提供 procedure 拆分示例。比如 debugging skill 可以拆成：reproduce → isolate → root-cause → fix-verify 四个 procedure 文件。

  ---
3. Quality Gate 模板 (HIGH)

devpace 的三门质量关卡是核心亮点：
- Gate 1: 自动化（lint + format + tests）
- Gate 2: 集成一致性（需求覆盖 + 架构合规）
- Gate 3: 人类审批（Hook 强制执行，不可绕过）

harness-kit 现状：有 require-tests.sh、require-lint.sh 等 hook，但没有体系化的 Gate 概念。

建议：创建 templates/universal/quality-gates/ 模板：
- 定义 Gate 1/2/3 的标准模板
- 提供对应 hook 组合配置
- 强调 Gate 3 不可绕过的架构设计

  ---
4. 跨 Session 上下文恢复 (MEDIUM)

devpace 的 .devpace/state.md 自动保存和恢复会话状态：
- 当前正在做什么
- 下一步是什么
- 进度到哪里了

harness-kit 现状：完全没有涉及跨 session 连续性。

建议：在 guides/ 中增加「Session Continuity」指南，或在 templates/claude-code/ 下提供 session-state/ 模板，展示如何用 PreSessionStart hook 自动加载状态。

  ---
5. 复杂度自适应模板 (MEDIUM)

devpace 根据 CR 复杂度（S/M/L/XL）适配不同细节要求：
- S: 自由文本验收标准，无需计划
- L/XL: Given/When/Then 验收 + 强制实现计划 + 严格 schema

harness-kit 现状：模板是 one-size-fits-all。

建议：在 AGENTS.md 模板中引入复杂度分级概念。比如 standard.md 模板可以加入：
## Task Complexity Guide
- S (1-2 files): Just do it, minimal ceremony
- M (3-5 files): Write plan before coding
- L (6+ files): Full design doc + review gate

  ---
6. Traceability Markers (MEDIUM)

devpace 用 HTML 注释追踪数据来源：
- **产品功能**：PF-001 ← <!-- source: user -->
- **范围**：文件上传 ← <!-- source: claude, auto-inferred -->

harness-kit 现状：无此概念。

建议：在 error-driven-writing guide 中补充「溯源标记」最佳实践 — 标记哪些规则来自用户观察，哪些是 agent 推断。这对规则维护极其重要。

  ---
7. Layer Separation 强制 (LOW-MEDIUM)

devpace 有 test_layer_separation.py 确保产品层不引用开发层。

harness-kit 现状：research/ 是只读的规则写在 AGENTS.md 里，但无自动化检测。

建议：加一个简单的 CI check，确保 templates/ 下的文件不引用 research/ 路径。

  ---
8. LLM 行为评估框架 (LOW — 长期)

devpace 有完整的评估体系：
- Trigger eval：skill 是否在正确场景自动触发
- Behavior eval：输出是否符合预期风格
- Regression eval：改动是否破坏已有行为

harness-kit 现状：零 LLM 评估。

建议：长期目标。可以先从简单的开始 — 比如验证 harness-kit init 生成的文件能否被 Claude Code 正确解析和遵循。

  ---
不建议照搬的部分

┌─────────────────────┬──────────────────────────────────────┐
│    devpace 特性     │       为什么不适合 harness-kit       │
├─────────────────────┼──────────────────────────────────────┤
│ Plugin 架构         │ harness-kit 定位是生成器，不是运行时 │
├─────────────────────┼──────────────────────────────────────┤
│ 完整 BizDevOps 流程 │ 过重，harness-kit 追求轻量           │
├─────────────────────┼──────────────────────────────────────┤
│ .devpace/ 状态文件  │ harness-kit 生成后不介入运行         │
├─────────────────────┼──────────────────────────────────────┤
│ 三角色 Agent 委托   │ 属于 devpace 产品差异化，非通用模式  │
├─────────────────────┼──────────────────────────────────────┤
│ DORA 度量           │ 需要运行时数据，生成器做不了         │
└─────────────────────┴──────────────────────────────────────┘

  ---
总结

最值得立即行动的三件事：
1. 模板验证测试 — 当前模板零自动化检查，风险最大
2. Quality Gate 模板 — 比零散的 hook 更有体系感，用户更容易理解
3. Skill Procedure 拆分示例 — 展示如何处理复杂场景，提升模板实用性