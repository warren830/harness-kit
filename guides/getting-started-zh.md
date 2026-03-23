# harness-kit 快速开始

> 5 分钟为你的项目搭建 AI Agent 驾驭系统。

---

## 前置条件

- Python 3.11+
- 一个你想添加 Harness 的现有项目
- Claude Code、Kiro 或两者都有

## 第一步：安装 harness-kit

```bash
pip install harness-kit
# 或
pipx install harness-kit
```

## 第二步：初始化项目 Harness

```bash
# 交互模式（推荐首次使用）
harness-kit init ~/my-project/

# 非交互模式
harness-kit init ~/my-project/ --tools both --type web-app --level 2
```

初始化向导会问三个问题：

| 问题 | 选项 | 建议 |
|------|------|------|
| 使用哪些 AI 工具？ | `claude-code`, `kiro`, `both` | 选你日常用的 |
| 项目类型？ | `web-app`, `api-service`, `cli-tool`, `data-pipeline`, `ml-project` | 选最接近的 |
| Harness 级别？ | 1 (仅规则), 2 (+约束), 3 (完整) | 建议从 **2** 开始 |

### 会生成什么

**Level 1**（仅规则）：
```
AGENTS.md           — 通用 Agent 指令（Kiro 自动识别，Claude Code 通过 @导入）
CLAUDE.md           — Claude Code 配置
.kiro/steering/     — Kiro 配置
docs/ARCHITECTURE.md — 架构文档骨架
```

**Level 2**（+约束）：
```
... Level 1 的全部，加上：
.claude/hooks/require-tests.sh  — Stop 钩子：提交前必须通过测试
.claude/hooks/auto-lint.sh      — PostToolUse 钩子：每次编辑后自动 lint
```

**Level 3**（完整）：
```
... Level 2 的全部，加上：
.claude/settings.json  — Hooks 配置文件
```

## 第三步：自定义 AGENTS.md

打开生成的 `AGENTS.md`，替换所有 `[方括号]` 中的占位符为你项目的真实信息。

**但"Agent Pitfalls"段落保持留空** — 这个段落通过实际观察 Agent 犯错来逐步填写。

## 第四步：开始使用 AI Agent

正常使用 Claude Code 或 Kiro。当 Agent 犯错时：

1. 记录出了什么问题
2. 在 AGENTS.md 的 "Agent Pitfalls" 段落加一行
3. 重新执行同样的任务 — 确认错误不再发生

这就是**错误驱动编写法** — 核心方法论。详见 [error-driven-writing.md](error-driven-writing.md)。

## 第五步：检查进度

```bash
# 查看 Harness 成熟度评分
harness-kit score ~/my-project/

# 检测熵（过时规则、未填占位符）
harness-kit scan ~/my-project/
```

## 接下来做什么？

| 当前评分 | 下一步 | 指南 |
|---------|--------|------|
| Level 1-2 | 添加 Hooks（验证门） | claude-code-harness.md |
| Level 2-3 | 添加 Skills（渐进式上下文） | claude-code-harness.md |
| Level 3-4 | 添加 Kiro Specs（结构化规划） | kiro-harness.md |
| Level 4-5 | 建立熵管理机制 | `templates/universal/entropy/` |
| Level 5+ | 多 Agent 工作流 | dual-tool-workflow.md |

## 常见问题

**Q：必须同时用 Claude Code 和 Kiro 吗？**
不需要。用什么就配什么，以后需要再加。AGENTS.md 两者都能识别。

**Q：我的项目不匹配任何预设类型怎么办？**
选最接近的，然后自定义。预设是起点，不是限制。

**Q：多久能看到效果？**
第一个改善来自 AGENTS.md 本身 — 通常在前几个 Agent 任务内就能感受到。Hooks 带来第二个跃升。大多数团队一周内就能看到可量化的改善。

**Q：能和 Cursor/Copilot 一起用吗？**
AGENTS.md 被 Cursor 和 Copilot 识别。Hooks 和 Skills 模板目前是 Claude Code 专属。其他平台支持在规划中。
