# 研究：驾驭工程（Harness Engineering）的技术实现细节

## 1. 定义与核心概念

**驾驭工程（Harness Engineering）** 指的是围绕 AI 编程代理（AI coding agent）设计基础设施、规则、工具和反馈回路的实践——将原始语言模型转变为可靠且高效的软件工程助手。正如 Anthropic 官方文档所述：

> "Claude Code serves as the **agentic harness** around Claude: it provides the tools, context management, and execution environment that turn a language model into a capable coding agent."
>
> Claude Code 作为 Claude 的**智能体驾驭层（agentic harness）**：它提供工具、上下文管理和执行环境，将语言模型转变为高效的编程代理。

该术语涵盖模型本身之外的一切：规则文件、钩子（Hooks）、权限系统、上下文管理、验证回路、成本优化以及 CI/CD 集成。

---

## 2. 各 AI 编程代理的规则文件（Rule Files）

### 2.1 Claude Code：CLAUDE.md

**位置与作用域层级（优先级从高到低）：**

| 作用域 | 位置 | 用途 |
|--------|------|------|
| 托管策略（Managed policy） | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | 组织级别，不可排除 |
| 项目级（Project） | `./CLAUDE.md` 或 `./.claude/CLAUDE.md` | 通过版本控制进行团队共享 |
| 用户级（User） | `~/.claude/CLAUDE.md` | 跨所有项目的个人偏好 |

**关键技术细节：**
- 目标控制在每个文件 200 行以内；文件过长会降低遵循度
- 文件支持 `@path/to/import` 语法来导入其他文件（最多 5 层深度）
- 通过 `.claude/rules/` 目录实现路径特定规则（Path-specific rules），使用 YAML 前置元数据（frontmatter）的 glob 模式（例如 `paths: ["src/api/**/*.ts"]`）
- CLAUDE.md 作为**系统提示词之后的用户消息（user message after the system prompt）**加载，而非作为系统提示词的一部分
- 内容在 `/compact` 后仍然保留——从磁盘重新读取并重新注入
- `claudeMdExcludes` 设置可跳过单体仓库（monorepo）中不相关的文件
- 自动记忆系统（`~/.claude/projects/<project>/memory/MEMORY.md`）——每次会话加载前 200 行；Claude 自行编写笔记

### 2.2 GitHub Copilot：copilot-instructions.md

三种指令文件类型：
1. **仓库级（Repository-wide）**：`.github/copilot-instructions.md`——适用于所有请求
2. **路径特定（Path-specific）**：`.github/instructions/NAME.instructions.md`，使用 YAML 前置元数据 `applyTo: "**/*.ts,**/*.tsx"` 以及可选的 `excludeAgent: "code-review"` 或 `"coding-agent"`
3. **代理指令（Agent instructions）**：AGENTS.md 文件（或仓库根目录的 CLAUDE.md / `GEMINI.md`）——最近的文件优先

优先级：个人指令（最高） > 仓库级 > 组织级（最低）。

### 2.3 Cursor：.cursorrules

Cursor 最初使用项目根目录的 `.cursorrules` 文件。该系统后来重定向到位于 `docs.cursor.com/context/rules` 的更结构化的规则系统，但抓取时未能获取确切的当前架构（schema）。

### 2.4 OpenAI Codex：AGENTS.md

OpenAI 的 Codex 代理使用 AGENTS.md 文件进行仓库级指令配置，模式与 Claude 的 CLAUDE.md 类似。GitHub Copilot 同样将 AGENTS.md 识别为代理指令文件。

---

## 3. 确定性护栏：钩子系统（Hooks System）

Claude Code 的钩子系统（Hooks System）提供**确定性执行保障（deterministic enforcement）**，而非 CLAUDE.md 的建议性指令。钩子在 24 个以上的生命周期节点（lifecycle points）触发：

```
SessionStart -> UserPromptSubmit -> PreToolUse -> PermissionRequest -> PostToolUse
-> SubagentStart/Stop -> Stop/StopFailure -> TaskCompleted -> SessionEnd
```

### 四种钩子处理器类型：

1. **命令钩子（Command hooks）**（Shell 脚本）：通过 stdin 接收 JSON，通过 stdout 输出 JSON。退出码 0 = 允许，退出码 2 = 阻断错误。
2. **HTTP 钩子（HTTP hooks）**：向端点发送 POST 请求，携带 JSON 载荷，支持在请求头中使用环境变量插值。
3. **提示词钩子（Prompt hooks）**：使用 Claude 模型进行单轮 LLM 评估（是/否决策）。
4. **代理钩子（Agent hooks）**：生成子代理（subagent），配备 Read/Grep/Glob 工具进行复杂验证。

### 护栏模式与具体示例：

**阻止危险命令（PreToolUse）：**
```bash
#!/bin/bash
COMMAND=$(jq -r '.tool_input.command' < /dev/stdin)
if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: "Destructive command blocked"}}'
else
  exit 0
fi
```

**PostToolUse 代码检查（lint）执行：**
```bash
if [[ "$TOOL" == "Write" || "$TOOL" == "Edit" ]]; then
  if ! npx eslint "$FILE" --fix 2>/dev/null; then
    jq -n '{decision: "block", reason: "File fails linting."}'
  fi
fi
```

**Stop 钩子要求测试通过后才能停止：**
```bash
if ! npm test >/dev/null 2>&1; then
  jq -n '{decision: "block", reason: "Tests failing. Fix test failures before stopping."}'
fi
```

**关键区别**：

> "Settings rules are enforced by the client regardless of what Claude decides to do. CLAUDE.md instructions shape Claude's behavior but are not a hard enforcement layer."
>
> 设置规则（Settings rules）由客户端强制执行，不受 Claude 决策影响。CLAUDE.md 指令塑造 Claude 的行为，但并非硬性执行层。

---

## 4. KV 缓存 / 提示词缓存（Prompt Caching）的成本优化

### 定价（每百万 token）：

| 模型 | 基础输入 | 缓存写入（5分钟） | 缓存写入（1小时） | **缓存命中** | 输出 |
|------|---------|-----------------|-----------------|------------|------|
| Claude Sonnet 4.6 | **$3** | $3.75 | $6 | **$0.30** | $15 |
| Claude Opus 4.6 | $5 | $6.25 | $10 | **$0.50** | $25 |
| Claude Haiku 4.5 | $1 | $1.25 | $2 | **$0.10** | $5 |

**从 $3 降至 $0.30**：对于 Claude Sonnet 4.6，缓存 token 读取成本为 $0.30/百万 token，而基础输入为 $3/百万 token——**成本降低 90%**（即每百万 token 从 $3 降至 $0.3，精确的 10 倍降幅）。

**定价乘数：**
- 缓存写入：基础输入的 1.25 倍（5 分钟 TTL）或 2 倍（1 小时 TTL）
- **缓存读取：基础输入的 0.1 倍（10%）**——这是关键节省所在

**实际案例**：使用 Opus 进行 50k token 法律文档分析：
- 首次请求（缓存写入）：$0.325
- 后续请求（缓存命中）：每次 $0.038——**每次请求节省 88%**
- 9 次后续请求共节省 $2.52

**技术限制：**
- 最小可缓存 token 数：2,048（Sonnet 4.6）、4,096（Opus / Haiku 4.5）
- 每次请求最多 4 个缓存断点（cache breakpoints）
- 20 个块的回溯窗口（lookback window）用于缓存匹配
- 默认 5 分钟 TTL（每次使用时刷新）；可选 1 小时 TTL

---

## 5. 渐进式上下文披露（Progressive Context Disclosure）

### 技能系统（Skills System）——按需加载

技能（Skills，即 `.claude/skills/` 中的 SKILL.md 文件）实现了渐进式上下文披露：

- **会话开始时加载描述**（轻量级）——Claude 看到可用的技能
- **完整技能内容仅在调用时加载**——节省上下文 token
- 字符预算：上下文窗口的 2%（回退值：16,000 个字符）
- `disable-model-invocation: true` 将技能完全移出上下文，直到手动调用

### 路径特定规则（Path-Specific Rules）

`.claude/rules/` 中的文件带有 `paths` 前置元数据，仅在 Claude 处理匹配文件时才加载：
```yaml
---
paths:
  - "src/api/**/*.ts"
---
# API Development Rules
```

### 子代理上下文隔离（Subagent Context Isolation）

子代理在独立的上下文窗口中运行。它们的冗长文件读取、测试输出和探索操作不会膨胀主对话上下文。只有摘要返回。

### 文档中的上下文管理策略：
- 在不相关任务之间使用 `/clear`
- 自动压缩（Auto-compaction）在接近限制时进行摘要
- `/compact <instructions>` 用于有针对性的压缩（例如 `/compact Focus on the API changes`）
- 通过 CLAUDE.md 指令控制压缩行为：`"When compacting, always preserve the full list of modified files"`
- MCP 工具搜索：当工具描述超过上下文的 10% 时，工具被延迟加载并按需加载

---

## 6. 自我验证回路（Self-Verification Loops）

官方最佳实践将自我验证确定为**"你能做的最高杠杆率的事"**：

> "the single highest-leverage thing you can do"

**验证策略：**

| 策略 | 改进前 | 改进后 |
|------|--------|--------|
| 提供验证标准 | "implement a function that validates email addresses"（实现一个验证邮箱地址的函数） | "write validateEmail. Test cases: user@example.com true, invalid false. Run tests after implementing"（编写 validateEmail。测试用例：user@example.com 为 true，invalid 为 false。实现后运行测试） |
| 视觉验证 | "make the dashboard look better"（让仪表盘更好看） | "[paste screenshot] implement this design. Take screenshot and compare"（[粘贴截图] 实现此设计。截图并对比） |
| 根因分析 | "the build is failing"（构建失败了） | "the build fails with this error: [paste]. Fix it and verify build succeeds"（构建以此错误失败：[粘贴]。修复并验证构建成功） |

**Stop 钩子作为验证关卡**：Stop 钩子可以阻止 Claude 完成任务，直到 `npm test && npm run lint` 通过。

**编写者/审查者模式（Writer/Reviewer pattern）**：两个并行会话——会话 A 负责实现，会话 B 以全新上下文进行审查（避免对自己编写的代码产生偏见）。

---

## 7. 基准测试与量化结果

### SWE-bench Verified 得分：

| 代理/模型 | 得分 | 成本 | 日期 |
|-----------|------|------|------|
| Claude 4.5 Opus（高推理） | **76.8%** | 总计 $376.95 | 2026 年 2 月 |
| Gemini 3 Flash（高推理） | 75.8% | 总计 $177.98 | 2026 年 2 月 |
| Claude 3.5 Sonnet（新版，2024） | 49% | -- | 2024 |
| 此前最优（Previous SOTA，2024） | 45% | -- | 2024 |
| Claude 3.5 Sonnet（旧版） | 33% | -- | 2024 |
| Claude 3 Opus | 22% | -- | 2024 |

**来自 SWE-bench 的关键脚手架洞察（scaffolding insight）**：

> The developers "prioritized giving as much control as possible to the language model itself, and keep the scaffolding minimal."
>
> 开发者"优先将尽可能多的控制权交给语言模型本身，并保持脚手架最小化。"

该系统仅使用两个主要工具（Bash 和 Edit），其中 Edit 工具要求精确的单一匹配字符串替换以确保精度。模型持续采样直到完成或达到 200k token 预算。

### Claude Code 成本指标：
- **平均成本：每开发者每天 $6**
- 90% 的用户日均低于 $12
- 月均约 $100-200/开发者（使用 Sonnet 4.6）
- 代理团队（Agent teams）使用的 token 约为标准会话的 7 倍
- 后台 token 使用量：每次会话通常低于 $0.04

### 代码审查成本：
- 平均审查成本：每个 PR $15-25
- 多代理舰队（Multi-agent fleet），支持并行分析和去重
- 平均完成时间：每次审查 20 分钟

---

## 8. CI/CD 集成 AI 代理

### GitHub Actions 集成

Claude Code 提供 `anthropics/claude-code-action@v1`：

```yaml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
jobs:
  claude:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

**模式**：自动检测（@claude 提及时为交互模式，提示词驱动时为自动化模式）。支持 AWS Bedrock 和 Google Vertex AI 后端。

**非交互模式**（用于 CI）：
```bash
claude -p "Analyze this log file" --output-format stream-json
```

**扇出模式（Fan-out pattern）**（用于批量操作）：
```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

### 自动化代码审查

多代理舰队（Multi-agent fleet），由专门的代理检查代码：
- 逻辑错误、安全漏洞、边界条件缺陷、隐蔽的回归问题
- 严重级别：Normal（缺陷）、Nit（小问题）、Pre-existing（非本次 PR 引入）
- 通过 `REVIEW.md` 自定义审查特定规则

---

## 9. AI 驱动的测试驱动开发（Test-Driven Development）

文档推广了明确的 TDD 模式：

1. **预先提供测试用例**："write validateEmail. Test cases: 'user@example.com' true, 'invalid' false, 'user@.com' false. Run tests after implementing"（编写 validateEmail。测试用例：'user@example.com' 为 true，'invalid' 为 false，'user@.com' 为 false。实现后运行测试）
2. **跨会话 TDD**："Have one Claude write tests, then another write code to pass them"（让一个 Claude 编写测试，然后另一个 Claude 编写代码来通过测试）
3. **Stop 钩子强制测试通过**：阻止代理在所有测试通过之前完成任务
4. **PostToolUse 钩子**：每次文件编辑后自动运行代码检查（lint）
5. **计划模式（Plan mode）**：先研究、再计划、然后实现、最后验证

---

## 10. 熵管理 / 垃圾回收（Entropy Management / Garbage Collection）

### 上下文熵（Context Entropy）

来自 Anthropic 最佳实践的核心洞察：

> "Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills."
>
> 大多数最佳实践基于一个约束：Claude 的上下文窗口填充速度很快，随着填充性能会下降。

**熵累积模式：**
- "厨房水槽会话（The kitchen sink session）"——混合不相关的任务污染上下文
- "反复纠正（Correcting over and over）"——失败的尝试用噪声填充上下文
- "无限探索（The infinite exploration）"——无范围的调查读取数百个文件
- "过度指定的 CLAUDE.md（The over-specified CLAUDE.md）"——重要规则淹没在噪声中

**垃圾回收策略：**
- 在不相关任务之间使用 `/clear`（硬重置）
- 使用 `/compact` 并附带指令以保留特定内容（选择性压缩）
- 使用 `/rewind` 将对话和代码恢复到检查点
- 子代理委托隔离冗长操作
- 接近上下文限制时触发自动压缩

### 文档漂移（Documentation Drift）

代码审查双向处理文档漂移：

> "If your PR changes code in a way that makes a CLAUDE.md statement outdated, Claude flags that the docs need updating too."
>
> 如果你的 PR 以使 CLAUDE.md 陈述过时的方式更改了代码，Claude 会标记文档也需要更新。

### 模式违规（Pattern Violations）

- `.claude/rules/` 中的路径特定模式按目录强制执行约定
- PostToolUse 钩子在每次编辑后运行代码检查器（linter）
- Stop 钩子在测试/代码检查通过前阻止完成
- REVIEW.md 编码"Claude 应始终标记的事项"和"Claude 应跳过的事项"

### 清理代理模式（Cleanup Agent Pattern）

`/simplify` 内置技能：

> "Review your recently changed files for code reuse, quality, and efficiency issues, then fix them. Spawns three review agents in parallel, aggregates findings, and applies fixes."
>
> 审查你最近更改的文件中的代码复用、质量和效率问题，然后修复它们。并行生成三个审查代理，汇总发现并应用修复。

`/batch` 技能用于大规模清理：

> "Researches the codebase, decomposes work into 5-30 independent units, spawns one background agent per unit in isolated git worktrees."
>
> 研究代码库，将工作分解为 5-30 个独立单元，在隔离的 git 工作树（worktree）中为每个单元生成一个后台代理。

---

## 11. 缓存之外的成本优化技术

1. **MCP 工具搜索**：当工具超过上下文的 10% 时，自动延迟加载。通过 `ENABLE_TOOL_SEARCH=auto:<N>` 配置（例如 `auto:5` 表示 5% 阈值）
2. **优先使用 CLI 工具而非 MCP 服务器**：`gh`、`aws`、`gcloud` 不会添加持久化的工具定义
3. **将 CLAUDE.md 内容转移到技能中**：技能按需加载；CLAUDE.md 每次会话都会加载
4. **代码智能插件（Code intelligence plugins）**：单次"跳转到定义"调用替代 grep 加读取多个文件
5. **预处理钩子（Preprocessing hooks）**：在 Claude 查看之前将 10,000 行日志过滤为仅 ERROR 行
6. **扩展思考控制（Extended thinking control）**：`MAX_THINKING_TOKENS=8000` 或 `/effort low` 用于简单任务
7. **模型选择**：Sonnet 用于大多数任务，Opus 用于复杂架构，Haiku 用于简单子代理任务

**按团队规模的速率限制建议：**

| 团队规模 | 每用户 TPM | 每用户 RPM |
|----------|-----------|-----------|
| 1-5 人 | 200k-300k | 5-7 |
| 5-20 人 | 100k-150k | 2.5-3.5 |
| 100-500 人 | 15k-20k | 0.37-0.47 |
| 500+ 人 | 10k-15k | 0.25-0.35 |

---

## 12. 总结：驾驭工程技术栈（The Harness Engineering Stack）

AI 辅助开发的完整驾驭工程技术栈包括：

1. **规则层（Rule layer）**：CLAUDE.md / copilot-instructions.md / AGENTS.md / .cursorrules——建议性行为指导
2. **确定性层（Deterministic layer）**：Hooks（PreToolUse、PostToolUse、Stop）——强制执行的 Shell 脚本护栏
3. **权限层（Permission layer）**：允许列表（Allowlists）、拒绝列表（Denylists）、沙箱（Sandboxing）——安全边界
4. **上下文层（Context layer）**：技能（Skills）、路径特定规则、子代理、自动压缩——渐进式披露与熵管理
5. **验证层（Verification layer）**：测试套件、代码检查器、截图、Stop 钩子——自检回路
6. **成本层（Cost layer）**：KV 缓存（节省 90%）、模型选择、工具搜索阈值——经济优化
7. **CI/CD 层（CI/CD layer）**：GitHub Actions、GitLab CI/CD、非交互模式——规模化自动化
8. **审查层（Review layer）**：多代理代码审查、REVIEW.md、严重级别标记——质量保障
