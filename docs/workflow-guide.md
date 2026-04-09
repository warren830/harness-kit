# Harness-Kit 使用流程指南

> 本文档以流程图形式展示 harness-kit 的核心使用方法，帮助你快速理解从安装到日常使用的完整工作流。

---

## 目录

1. [总览：Harness Engineering 概念](#1-总览harness-engineering-概念)
2. [快速开始流程](#2-快速开始流程)
3. [Error-Driven Writing 核心方法论](#3-error-driven-writing-核心方法论)
4. [Claude Code Harness 五层架构](#4-claude-code-harness-五层架构)
5. [Kiro Harness 三支柱架构](#5-kiro-harness-三支柱架构)
6. [双工具协作流程](#6-双工具协作流程)
7. [Harness 成熟度演进](#7-harness-成熟度演进)
8. [CI/CD 自动化流程](#8-cicd-自动化流程)
9. [日常工作流程](#9-日常工作流程)
10. [CLI 命令速查](#10-cli-命令速查)

---

## 1. 总览：Harness Engineering 概念

### 核心公式

```
AI Agent = Model（智能） + Harness（约束系统）
```

Harness-kit 提供的不是 AI 模型本身，而是围绕 AI 编码代理（Claude Code / Kiro）构建的**约束、反馈循环和控制系统**。

### 项目定位流程图

![项目定位](images/01-project-positioning.png)

**说明：**
- **HARNESS.md** 是所有工具共享的单一事实来源（Single Source of Truth）
- 每个平台有自己的配置层（CLAUDE.md / Steering），但核心规则不重复
- 最终目标：让 AI 代理在约束下更好地工作，而非自由发挥

---

## 2. 快速开始流程

### 从安装到开始使用（5 分钟）

![快速开始流程](images/02-quick-start.png)

### 初始化命令示例

```bash
# 最简模式 — 适合个人项目
harness-kit init --tools claude-code --type web-app --level 1

# 标准模式 — 适合团队项目
harness-kit init --tools both --type api-service --level 2

# 完整模式 — 适合大型项目
harness-kit init --tools claude-code --type web-app --level 3
```

### 各等级生成的文件

| 等级 | 生成内容 | 适用场景 |
|------|---------|---------|
| Level 1 | HARNESS.md + 平台配置 + ARCHITECTURE.md | 个人项目、快速原型 |
| Level 2 | + Hooks 验证门 + 约束模板 | 团队项目、正式开发 |
| Level 3 | + settings.json 完整连接 | 大型项目、需要严格管控 |

---

## 3. Error-Driven Writing 核心方法论

这是 harness-kit **最重要的理念**：所有规则都来自观察到的失败，而非预设猜测。

### 核心循环

![Error-Driven 核心循环](images/03-error-driven-loop.png)

### 关键原则

![规则编写指南](images/04-rules-good-bad.png)

### 研究数据支撑

| 方法 | 效果 |
|------|------|
| 人工编写 + Error-Driven 的 HARNESS.md | **+4% 性能提升** |
| AI 自动生成的 HARNESS.md | **-20% 性能下降** |
| 没有 HARNESS.md | 基准线 |

> 来源：ETH Zurich 研究（2025）

---

## 4. Claude Code Harness 五层架构

### 架构总览

![Claude Code 五层架构](images/05-claude-five-layers.png)

### Hook 执行流程

![Hook 执行时序](images/06-hook-sequence.png)

### Hook 优先级建议

![Hook 优先级](images/07-hook-priority.png)

---

## 5. Kiro Harness 三支柱架构

### 架构总览

![Kiro 三支柱架构](images/08-kiro-three-pillars.png)

### Steering 加载模式详解

![Steering 加载模式](images/09-steering-loading.png)

### Kiro Feature Spec 工作流

![Kiro Feature Spec 流程](images/10-kiro-feature-spec.png)

---

## 6. 双工具协作流程

### 核心原则：Kiro 规划，Claude Code 执行

![双工具协作流程](images/11-dual-tool-collaboration.png)

### 四种协作场景

![四种协作场景](images/12-four-scenarios.png)

### 共享桥梁：HARNESS.md

![共享 HARNESS.md](images/13-shared-harness-md.png)

---

## 7. Harness 成熟度演进

### 七级成熟度模型

![成熟度等级](images/14-maturity-levels.png)

### 每级详细说明

![成熟度详细说明](images/15-maturity-detail.png)

### 评分等级

| 分数范围 | 等级 | 含义 |
|---------|------|------|
| 0–15 | F | 基本没有约束 |
| 16–30 | D | 有基础规则 |
| 31–45 | C | 有约束和验证 |
| 46–60 | B | 有反馈和上下文 |
| 61–70 | A | 接近完整 |
| 71+ | S | 超越标准 |

### 推荐演进时间线

![成熟度演进计划](images/16-maturity-gantt.png)

---

## 8. CI/CD 自动化流程

### 两个 CI 工作流

![CI/CD 工作流](images/17-ci-cd-workflows.png)

### 熵扫描检测项

![熵扫描检测项](images/18-entropy-scan-items.png)

---

## 9. 日常工作流程

### 推荐的每日流程

![日常工作流程](images/19-daily-workflow.png)

### HARNESS.md 更新决策树

![HARNESS.md 更新决策树](images/20-harness-md-decision-tree.png)

---

## 10. CLI 命令速查

### 命令总览

![CLI 命令总览](images/21-cli-commands.png)

### 命令用法

```bash
# 初始化 harness（交互式）
harness-kit init

# 初始化 harness（指定参数）
harness-kit init ~/my-project --tools claude-code --type web-app --level 2

# 跳过已存在的文件
harness-kit init --skip-existing

# 查看项目 harness 成熟度评分
harness-kit score ~/my-project

# 以 JSON 格式输出评分
harness-kit score --format json

# 扫描项目中的熵（drift）
harness-kit scan ~/my-project
```

---

## 附录：模板清单

### 所有可用模板

| 类别 | 模板 | 数量 | 说明 |
|------|------|------|------|
| **Universal** | HARNESS.md 变体 | 4 | minimal / standard / monorepo / writing-guide |
| | Knowledge Base | 7 | ARCHITECTURE / QUALITY / BELIEFS / TECH-DEBT 等 |
| | Constraints | 2 | layer-rules / error-message-design |
| | Entropy | 3 | golden-principles / quality-grades / weekly-review |
| **Claude Code** | Hooks | 6 | PreToolUse ×2 / PostToolUse ×2 / Stop ×2 |
| | Skills | 12 | code-review / debugging / refactoring 等 |
| | Rules | 3 | api / test / ui |
| **Kiro** | Steering | 7 | always ×3 / auto ×2 / manual ×1 等 |
| | Specs | 5 | feature / bugfix 模板 |
| | Hooks | 2 | on-save-lint / after-task-test |
| **Combo** | Dual-Tool | 1 | 协作脚手架 |
| **Environments** | Isolation | - | Docker / Worktree 模板 |

---

> **提示：** 本文档中的 Mermaid 流程图可以在 GitHub、VS Code（安装 Mermaid 插件）、或任何支持 Mermaid 的 Markdown 渲染器中查看。
