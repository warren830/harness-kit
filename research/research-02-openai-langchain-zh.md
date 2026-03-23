# 研究：OpenAI 报告与 LangChain 案例研究

## 1. OpenAI 官方报告："Harness Engineering: Leveraging Codex in an Agent-First World"

**URL:** https://openai.com/index/harness-engineering/
**发布日期：** 2026 年 2 月 11 日
**作者：** Ryan Lopopolo，技术团队成员（Member of the Technical Staff）
**致谢：** Victor Zhu 和 Zach Brock

### 案例研究：3 名工程师，约 100 万行代码，5 个月

关键事实与原文引用：

- **"Over the past five months, our team has been running an experiment: building and shipping an internal beta of a software product with 0 lines of manually-written code."**
  过去五个月，我们的团队一直在进行一项实验：构建并交付一款内部测试版软件产品，其中手动编写的代码为 0 行。
- 第一次提交（commit）于 **2025 年 8 月下旬** 落入一个空仓库
- **"Five months later, the repository contains on the order of a million lines of code across application logic, infrastructure, tooling, documentation, and internal developer utilities."**
  五个月后，该仓库包含了约一百万行代码，涵盖应用逻辑、基础设施、工具链、文档和内部开发工具。
- **"Over that period, roughly 1,500 pull requests have been opened and merged with a small team of just three engineers driving Codex."**
  在此期间，仅由三名工程师驱动 Codex，就提交并合并了约 1,500 个拉取请求（Pull Request）。
- **"This translates to an average throughput of 3.5 PRs per engineer per day, and surprisingly the throughput has increased as the team has grown to now seven engineers."**
  这意味着每位工程师每天平均产出 3.5 个 PR，令人惊讶的是，随着团队扩展至七名工程师，吞吐量反而有所提升。
- **"We estimate that we built this in about 1/10th the time it would have taken to write the code by hand."**
  我们估计，这大约只用了手写代码所需时间的十分之一。
- 使用 **Codex CLI（基于 GPT-5）** 完成初始脚手架搭建
- **"Throughout the development process, humans never directly contributed any code. This became a core philosophy for the team: no manually-written code."**
  在整个开发过程中，人类从未直接贡献任何代码。这成为团队的核心理念：不手写代码。

### 核心理念

**"Humans steer. Agents execute."**
人类掌舵，智能体（Agent）执行。

**"We intentionally chose this constraint so we would build what was necessary to increase engineering velocity by orders of magnitude. We had weeks to ship what ended up being a million lines of code."**
我们有意选择了这一约束，以便构建出将工程速度提升数个数量级所需的一切。我们用数周时间交付了最终达到百万行的代码。

### "永不再犯同样的错误"概念

文章将此表述为：**"When the agent struggles, we treat it as a signal: identify what is missing—tools, guardrails, documentation—and feed it back into the repository, always by having Codex itself write the fix."**
当智能体遇到困难时，我们将其视为一个信号：识别缺少了什么——工具、护栏、文档——然后将其反馈到仓库中，始终由 Codex 自身来编写修复。

以及：**"what capability is missing, and how do we make it both legible and enforceable for the agent?"**
缺少了什么能力，我们如何使其对智能体既可读又可执行？

### 驾驭工程（Harness Engineering）的组件框架

文章描述了以下相互关联的组件：

**A. 仓库知识作为记录系统（System of Record）**
- AGENTS.md 作为 **"目录"（the table of contents）**，而非百科全书（约 100 行）
- 结构化的 `docs/` 目录，包含设计文档（design-docs）、执行计划（exec-plans）、产品规格（product-specs）和参考资料（references）
- **渐进式信息披露（Progressive disclosure）**："agents start with a small, stable entry point and are taught where to look next, rather than being overwhelmed up front"
  智能体从一个小而稳定的入口开始，被教导下一步去哪里查找，而非一开始就被信息淹没。
- 代码检查工具（Linter）和 CI 任务验证知识库保持最新

**B. 智能体可读性（Agent Legibility）**
- **"From the agent's point of view, anything it can't access in-context while running effectively doesn't exist."**
  从智能体的角度来看，任何它在运行时无法在上下文中访问的内容，实际上都不存在。
- 存放在 Google Docs、Slack 或人们头脑中的知识对智能体是不可见的
- 偏好"无趣的"技术，以获得更好的可组合性和训练集覆盖
- 有时会重新实现库的子集，而非使用上游不透明的行为

**C. 架构约束（机械化强制执行）**
- 严格的分层领域架构：Types -> Config -> Repo -> Service -> Runtime -> UI
- 横切关注点（Cross-cutting concerns）通过单一、显式的"Providers"接口进入
- 自定义 Linter 和结构化测试强制执行依赖方向
- **"In a human-first workflow, these rules might feel pedantic or constraining. With agents, they become multipliers: once encoded, they apply everywhere at once."**
  在人类优先的工作流程中，这些规则可能显得迂腐或约束过多。但对于智能体，它们成为了放大器：一旦编码，便可同时在所有地方生效。
- Linter 的错误消息兼作修复指引，注入到智能体的上下文中

**D. 提升应用可读性（智能体环境）**
- 应用程序可按 git 工作树（worktree）启动（每个变更一个实例）
- Chrome DevTools Protocol 接入智能体运行时，配备 DOM 快照、截图、导航等技能（Skill）
- 完整的本地可观测性（Observability）技术栈：Vector -> Victoria Logs/Metrics/Traces，可通过 LogQL/PromQL/TraceQL 查询
- 每个工作树的环境是临时的（Ephemeral），任务完成后即销毁
- **"We regularly see single Codex runs work on a single task for upwards of six hours (often while the humans are sleeping)."**
  我们经常看到单次 Codex 运行在一个任务上持续工作超过六小时（通常是在人类睡觉时）。

**E. 吞吐量哲学**
- **"corrections are cheap, and waiting is expensive"**
  纠正的成本低廉，等待的代价高昂。
- 最小化阻塞式合并门禁（merge gates），采用短生命周期的 PR
- 智能体间互审（Ralph Wiggum Loop 模式）

**F. 熵与垃圾回收（Garbage Collection）**
- **"Our team used to spend every Friday (20% of the week) cleaning up 'AI slop.' Unsurprisingly, that didn't scale."**
  我们的团队曾经每周五（占一周 20% 的时间）用于清理"AI 垃圾代码（AI slop）"。不出所料，这种方式无法扩展。
- 将"黄金准则（Golden principles）"编码到仓库中，并配合循环清理智能体
- 后台 Codex 任务扫描偏差、更新质量评分、提交重构 PR
- **"Technical debt is like a high-interest loan"**
  技术债务（Technical debt）如同高息贷款。

**G. 不断提升的自主等级**
一条提示词（Prompt）现在可以触发：验证代码库 -> 复现缺陷 -> 录制故障视频 -> 实现修复 -> 通过驱动应用验证修复 -> 录制解决过程视频 -> 提交 PR -> 回应反馈 -> 检测/修复构建失败 -> 仅在需要判断时升级处理 -> 合并

### 仍在探索的领域

**"Our most difficult challenges now center on designing environments, feedback loops, and control systems that help agents accomplish our goal: build and maintain complex, reliable software at scale."**
我们目前最大的挑战集中在设计环境、反馈回路和控制系统上，以帮助智能体实现我们的目标：大规模构建和维护复杂、可靠的软件。

---

## 2. LangChain 案例研究：Terminal Bench 2.0 分数提升

**来源：** Vivek Trivedy (LangChain)，以 X（原 Twitter）文章形式发布
**URL:** https://x.com/Vtrivedy10/status/2023805578561060992
**另见：** https://blog.langchain.com/the-anatomy-of-an-agent-harness/ （2026 年 3 月 10 日）

### 关键数据

- **起始分数：52.8%**，使用默认提示词和标准工具 + 中间件（Middleware），搭配 GPT-5.2-Codex（刚好在前 30 名之外）
- **最终分数：66.5%** —— 提升了 **13.7 个百分点**
- **从前 30 名升至前 5 名**，位列 Terminal Bench 2.0 排行榜
- **仅改变了驾驭层（Harness），模型（GPT-5.2-Codex）保持不变**

### Terminal Bench 2.0 排行榜背景（来自 tbench.ai）

- ForgeCode agent 搭配 Opus 4.6：81.8% +/- 1.7（排名第 1）
- Anthropic 的 Claude Code 搭配 Opus 4.6：58.0% +/- 2.9（排名第 39）
- Claude Code 搭配 Opus 4.5：52.1% +/- 2.5（排名第 48）
- Deep Agents (LangChain) 搭配 GPT-5.2-Codex：66.5% +/- 3.1（排名第 21）
- Terminal Bench 包含 89 项任务，覆盖机器学习（ML）、调试（Debugging）和生物学（Biology）领域

### 改进方案

三个优化旋钮：**系统提示词（System Prompt）、工具（Tools）和中间件（Middleware）**（围绕模型和工具调用的钩子）

**第 1 步 - 自动化轨迹分析技能（Automated Trace Analysis Skill）：**
1. 从 LangSmith 获取实验轨迹（Trace）
2. 派生并行的错误分析智能体；主智能体综合发现结果并给出建议
3. 汇总反馈，对驾驭层进行针对性修改
- 人类参与有帮助但非必需（在第 3 步中）
- 对单一任务过拟合（Overfit）的修改不利于泛化能力

**第 2 步 - 自我验证（Self-Verification）：**
增加了结构化的问题解决引导：
1. 规划与探索（Planning & Discovery）：阅读任务、扫描代码库、制定初始计划
2. 构建（Build）：以验证为导向进行实现，编写测试
3. 验证（Verify）：运行测试，对照规格说明（而非自身代码）进行比较
4. 修复（Fix）：分析错误，回顾原始规格说明

使用 **PreCompletionChecklistMiddleware** 在智能体退出前拦截，强制进行验证环节（类似 Ralph Loop）。

**第 3 步 - 上下文工程（Context Engineering）：**
- **LocalContextMiddleware**：在智能体启动时映射当前工作目录和目录结构，发现可用工具
- 告知智能体其代码将通过程序化测试进行评估
- **时间预算（Time budgeting）**：注入时间预算警告，推动智能体从实现阶段转向验证阶段

**第 4 步 - 循环检测（Loop Detection）：**
**LoopDetectionMiddleware** 通过工具调用钩子（Hook）追踪每个文件的编辑次数，在对同一文件编辑 N 次后注入上下文提示，如"consider reconsidering your approach"（建议重新考虑你的方案）。

**第 5 步 - 推理算力优化（Reasoning Compute Optimization）：**
- GPT-5.2-Codex 有 4 种推理模式：low、medium、high、xhigh
- 仅使用 xhigh 模式得分 **53.9%**（因超时），而 high 模式得分 **63.6%**
- 使用 **"xhigh-high-xhigh 推理三明治"** 策略（在规划和验证阶段投入更多算力，实现阶段减少算力）
- 最终得分：**66.5%**

**跨模型说明：** 使用 Claude Opus 4.6 搭配早期版本驾驭层的测试得分为 **59.6%**，具有竞争力但低于 Codex，因为他们尚未针对 Claude 运行相同的改进迭代。

### Vivek Trivedy 的核心原则

1. 代替智能体进行上下文工程（Context Engineering）可减少错误面
2. 帮助智能体积极进行自我验证
3. 将轨迹追踪（Tracing）作为自我评估的反馈信号
4. 检测并修复不良模式（护栏机制将随模型改进而逐步淡化）
5. 为模型量身定制驾驭层——原则具有通用性，但针对特定模型的迭代仍然重要

### 来自《The Anatomy of an Agent Harness》博客文章

**"Agent = Model + Harness. If you're not the model, you're the harness."**
智能体 = 模型 + 驾驭层。如果你不是模型，那你就是驾驭层。

Vivek Trivedy 被认为是在 HumanLayer 文章中首创了"驾驭工程（Harness Engineering）"一词，其定义为 **"leveraging configuration points to customize and improve your coding agent's output quality and reliability."**
即"利用配置点来定制和提升编码智能体的输出质量与可靠性。"

---

## 3. 其他重要来源

### Martin Fowler / Thoughtworks 分析（2026 年 2 月 17 日）
**URL:** https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html
**作者：** Birgitta Boeckeler

识别出 OpenAI 的三大驾驭类别：
1. **上下文工程（Context engineering）** —— 持续增强的知识库；动态上下文，如可观测性数据和浏览器导航
2. **架构约束（Architectural constraints）** —— 由基于 LLM 的智能体以及确定性的自定义 Linter 和结构化测试进行监控
3. **"垃圾回收"（Garbage collection）** —— 定期运行的智能体，用于发现文档不一致和架构约束违规

### 新兴的驾驭工程实践手册（2026 年 2 月 24 日）
**URL:** https://www.ignorance.ai/p/the-emerging-harness-engineering

其他案例研究：
- **Stripe 的 Minions**：每周合并 1,000+ 个 PR，通过 MCP "Toolshed" 提供 400+ 个内部工具，智能体运行在预热的开发环境（devbox）中
- **Peter Steinberger (OpenClaw)**：每月 6,600+ 次提交，同时运行 5-10 个智能体

### AgentsMesh 案例研究（2026 年 3 月 14 日）
**URL:** https://agentsmesh.ai/blog/building-agentsmesh-with-agentsmesh

一人、52 天、**965,687 行** 代码吞吐量（356,220 行仍保留），600 次提交。在第 5 天左右，使用 3 个并发工作树（worktree）时达到认知带宽上限，约为每天 50,000 行。

---

## 4. Mitchell Hashimoto 的原始框架

在多个来源中被引用。HumanLayer 文章（2026 年 3 月 12 日，https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents ）将以下引文归于 Hashimoto：

**"anytime you find an agent makes a mistake, you take the time to engineer a solution such that the agent never makes that mistake again."**
每当你发现智能体犯了一个错误，你就花时间设计一个解决方案，确保智能体永远不会再犯同样的错误。

OpenAI 文章对同一概念的表述：**"When the agent struggles, we treat it as a signal: identify what is missing—tools, guardrails, documentation—and feed it back into the repository."**
当智能体遇到困难时，我们将其视为一个信号：识别缺少了什么——工具、护栏、文档——然后将其反馈到仓库中。
