# 研究：Thoughtworks、Stripe 及行业采纳情况

## 1. Birgitta Bockeler（Thoughtworks）及其框架

**来源：** https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html（发布于 2026 年 2 月 17 日）

Birgitta Bockeler 是 Thoughtworks 的杰出工程师（Distinguished Engineer），她在 Martin Fowler 的"探索生成式 AI（Exploring Generative AI）"系列中撰写了关于驾驭工程（Harness Engineering）的权威文章。她的文章分析了 OpenAI 在大规模维护 AI 生成代码方面的方法，并将其拆解为三个组成部分：

**上下文工程（Context Engineering）** -- 持续增强的、嵌入代码库的知识库，加上动态上下文访问（包括可观测性数据和浏览器导航）。Bockeler 强调，这需要大量的设计工作，远不止简单地整理文档。

**架构约束（Architectural Constraints）** -- 通过基于 LLM 的智能体和确定性自定义检查工具（linter）进行监控，包括结构测试强制边界、标准化模式以及模块边界定义。重点领域包括保持数据结构的稳定性以及定义/强制模块边界。

**熵管理（Entropy Management，"垃圾回收"）** -- 周期性运行的智能体，用于识别文档不一致并检测架构约束违规，以对抗代码库随时间推移的退化。

**Bockeler 的关键分析：**
- OpenAI 原始文章缺乏对实际功能和行为的验证——这是该框架中的一个重大缺口
- OpenAI 团队由三名工程师投入五个月进行工具开发，产出了百万行代码的产品，且"完全没有手动输入的代码（no manually typed code at all）"
- 她提出了驾驭（harness）是否会演变为通用应用架构的标准化服务模板的问题
- 她指出了一个反直觉的发现：约束运行时灵活性反而通过明确定义的边界赋予 AI 更大的自主权
- 她预测开发可能会趋向于更少的、"AI 友好型"技术栈
- 她质疑将驾驭改造到遗留代码库中是否值得付出努力，并将其类比为对未维护的代码运行静态分析，结果"淹没在告警中（drowning in alerts）"

OpenAI 团队的原文引用：

> "When the agent struggles, we treat it as a signal: identify what is missing -- tools, guardrails, documentation"
>
> 当智能体遇到困难时，我们将其视为一个信号：识别缺少了什么——工具、护栏还是文档。

> "Our most difficult challenges now center on designing environments, feedback loops, and control systems."
>
> 我们目前最困难的挑战集中在设计环境、反馈循环和控制系统上。

Bockeler 在该系列中的相关文章包括：
- "Context Engineering for Coding Agents"（编码智能体的上下文工程，2026 年 2 月 5 日）：https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html
- "I Still Care About the Code"（我仍然关心代码，2025 年 7 月 9 日）：https://martinfowler.com/articles/exploring-gen-ai/i-still-care-about-the-code.html
- "The Role of Developer Skills in Agentic Coding"（智能体编码中开发者技能的角色，2025 年 3 月 25 日）：https://martinfowler.com/articles/exploring-gen-ai/13-role-of-developer-skills.html

上下文工程文章详细介绍了具体工具：CLAUDE.md 文件（在会话开始时始终加载）、Rules（在访问相关文件时加载）、Skills（延迟加载的上下文）、Subagents（独立的上下文窗口）、MCP Servers（通过 Model Context Protocol 暴露 API）、Hooks（生命周期触发的脚本）以及 Plugins（分发机制）。她警告了"控制幻觉（Illusion of Control）"——尽管使用了"工程"这一术语，执行仍依赖于 LLM 的解释，团队应以概率而非确定性来思考。

---

## 2. Stripe 的 "Minions" 系统

**来源：**
- https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents（第一部分，2026 年 2 月 9 日，作者 Alistair Gray）
- https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents-part-2（第二部分，2026 年 2 月 19 日，作者 Alistair Gray）
- https://blog.bytebytego.com/p/how-stripes-minions-ship-1300-prs

**关键指标：** 每周合并超过 1,300 个拉取请求（Pull Request），所有请求均不包含人工编写的代码。所有 PR 在合并前均经过人工审查。

**为何自建：** Stripe 的代码库跨越数亿行代码，主要使用带有 Sorbet 类型系统的 Ruby（一种不常见的技术栈），拥有大量未纳入标准 LLM 训练数据的专有库。该代码"每年处理超过 1 万亿美元的支付交易量（moves well over $1 trillion per year of payment volume）"，面临复杂的金融、监管和合规要求。

**架构组件：**

*Devboxes：* 基于 AWS EC2 实例的标准化隔离开发环境。通过主动预配置（包含预热缓存和克隆仓库），在 10 秒内达到"热待命（hot and ready）"状态。文章强调 Devbox 是"牲畜而非宠物（cattle, not pets）"。它们运行在 QA 环境中，无法访问生产数据或进行任意网络外联。这些环境在智能体部署之前就已经为人类工程师预先存在。

*智能体驾驭（Agent Harness）：* Stripe 在 2024 年底分叉了 Block 的开源编码智能体 "Goose"，并针对其内部 LLM 基础设施进行了定制。与人工监督的工具（Cursor、Claude Code）不同，Minions 完全无人值守运行，没有中断能力或确认提示。

*蓝图（Blueprints）：* 将确定性节点（代码检查、推送变更）与智能体节点（"实现任务"、"修复 CI 失败"）混合编排的状态机。这种混合编排通过确保关键任务始终以相同方式执行来节省 token 并减少失败机会。

*规则文件（Rule Files）：* 采用 Cursor 格式的规则文件，作用域限定到特定目录和模式，避免全局规则造成的上下文窗口膨胀。

*模型上下文协议（Model Context Protocol, MCP）：* Stripe 构建了 "Toolshed"，一个集中式 MCP 服务器，包含近 500 个针对内部系统和 SaaS 平台的工具。Minions 接收经过精心策划的、与其任务相关的工具子集。

**开发周期：**
- 推送前代码检查（约 5 秒）
- 从总计 300 万以上测试中选择性运行 CI 测试
- 自动修复已知的失败模式
- CI 最多进行 2 轮，之后交还给人类工程师
- 此上限设计旨在防止边际效益递减

**入口点：** Slack 消息（最常见）、CLI、Web 界面以及内部应用程序（文档平台、功能开关系统、工单 UI）。

**关键洞察：** 该系统的成功与其说归功于 AI 模型本身，不如说归功于多年来在开发者生产力方面的基础设施投资——Devbox、测试框架以及反馈机制，这些同样惠及人类和智能体。其理念是：

> "If it's good for humans, it's good for LLMs, too."
>
> 对人类有益的，对 LLM 同样有益。

---

## 3. Thoughtworks 技术雷达（Technology Radar）相关内容

**来源：** https://www.thoughtworks.com/radar/techniques（第 33 期，2025 年 11 月）

"驾驭工程（Harness Engineering）"并未作为命名条目出现在技术雷达上。但多个密切相关的技术被收录：

**采纳环（Adopt）：**
- **为软件团队策划共享指令（Curated Shared Instructions for Software Teams）**（https://www.thoughtworks.com/radar/techniques/curated-shared-instructions-for-software-teams）-- 在软件交付中使用 AI 的团队应从个人提示词转向提交到项目仓库的策划指令。Cursor、Windsurf 和 Claude Code 等工具支持指令共享。这使得提示词能够持续改进。
- **预提交钩子（Pre-commit Hooks）** -- 使用 Git 钩子进行早期验证，特别是在 AI 辅助编码中用于密钥扫描。
- **使用生成式 AI 理解遗留代码库（Using GenAI to Understand Legacy Codebases）** -- 利用 AI 工具加速对复杂遗留系统的理解。

**试验环（Trial）：**
- **AGENTS.md**（https://www.thoughtworks.com/radar/techniques/agents-md）-- "为在项目中工作的 AI 编码智能体提供指令的通用格式（A common format for providing instructions to AI coding agents working on a project）。"基于 Markdown，无必填字段。典型用途包括编码环境中的工具使用提示、测试指令以及管理提交的首选实践。

**评估环（Assess）：**
- **上下文工程（Context Engineering）**（https://www.thoughtworks.com/radar/techniques/context-engineering）-- "系统性地设计和优化在推理过程中提供给大语言模型的信息（Systematically designing and optimizing information provided to large language models during inference）。"三个关键领域：上下文设置、长期任务的上下文管理，以及动态信息检索（即时上下文，JIT context）。
- **编码智能体团队（Team of Coding Agents）**（https://www.thoughtworks.com/radar/techniques/team-of-coding-agents）-- "开发者编排多个 AI 编码智能体，每个智能体承担不同角色——例如架构师、后端专家、测试人员——协作完成开发任务（A developer orchestrates multiple AI coding agents, each with a distinct role -- for example, architect, back-end specialist, tester -- to collaborate on a development task）。"支持此功能的工具：Claude Code、Roo Code、Kilo Code。
- **将编码智能体锚定到参考应用（Anchoring Coding Agents to a Reference Application）**（https://www.thoughtworks.com/radar/techniques/anchoring-coding-agents-to-a-reference-application）-- 通过提供一个可编译的活跃参考应用来引导生成式代码智能体，而非使用静态提示示例。使用 MCP 服务器暴露参考模板代码和提交差异。

**暂缓环（Hold，警示性的）：**
- **对 AI 生成代码的自满（Complacency with AI-generated code）** -- 质量下降的风险。
- **天真的 API 到 MCP 转换（Naive API-to-MCP conversion）** -- 暴露安全风险。

---

## 4. 其他采纳驾驭工程实践的公司

**OpenAI** -- 最早的实践者。其 Codex 团队由三名工程师在五个月内构建了一个百万行代码的内部产品，完全不使用手写代码，平均每位工程师每天提交 3.5 个 PR。他们实施了分层领域架构（Types -> Config -> Repo -> Service -> Runtime -> UI），每个子系统配备 88 个 AGENTS.md 文件。

**Stripe** -- Minions 系统每周产出 1,300 个以上合并的 PR（详见上文）。

**Anthropic** -- 使用 16 个并行的 Claude 智能体，在约 2,000 个会话中构建了一个 C 编译器，产出了 100,000 行生产级 Rust 代码。突破来自于最小化上下文污染、实施智能体专业化分工以及使用 CI 作为驾驭。其 Claude Agent SDK 被描述为一个"通用智能体驾驭（general-purpose agent harness）"，内置上下文管理功能。

**LangChain** -- 仅通过驾驭优化就展示了显著的改进（在 Terminal Bench 2.0 上从 52.8% 提升到 66.5%，排名从前 30 跃升至前 5），未更换模型。其 DeepAgents 产品"内置了默认提示词、工具处理、规划工具、文件系统访问等功能（default prompts, tool handling, planning utilities, file system access, and more baked in）"。

**Peter Steinberger（OpenClaw）** -- 每月提交超过 6,600 个 commit，同时运行 5-10 个智能体。

**Mitchell Hashimoto（Ghostty）** -- 记录了其六步 AI 采纳旅程，最终达到"第五步：设计驾驭（Step 5: Engineer the Harness）"（https://mitchellh.com/writing/my-ai-adoption-journey）。他的方法是：

> "I'm making an earnest effort whenever I see an agent do a Bad Thing to prevent it from ever doing that bad thing again."
>
> 每当我看到智能体做了不好的事情，我都会认真努力地防止它再次犯同样的错误。

两种机制：通过 AGENTS.md 文件实现更好的隐式提示，以及编程化工具（截图脚本、过滤测试等）。

**多家工具厂商**已采纳该概念：Cursor（规则文件）、Claude Code（CLAUDE.md、Hooks、Skills、Subagents）、Windsurf、GitHub Copilot（.github/copilot-instructions）以及 AGENTS.md 标准（由 OpenAI Codex、Amp、Jules、Cursor 和 Factory 协作形成）。

---

## 5. "五大核心组件"框架

"五大核心组件"框架的确切命名（上下文基础设施、渐进式披露、自验证、长时运行支持架构、反馈循环系统）并未作为单一归属框架出现在所找到的来源中。然而，这些概念以不同形式和组合出现在多个来源中：

**来自 alexlavaee.me**（https://alexlavaee.me/blog/harness-engineering-why-coding-agents-need-infrastructure/）的"驾驭工程四大支柱（Four Pillars of Harness Engineering）"：
1. 上下文架构（Context Architecture）-- 分层、渐进式披露（第一层：自动加载的项目概览；第二层：专业化子智能体上下文；第三层：文件系统知识库）
2. 智能体专业化（Agent Specialization）-- 具有受限工具和限定提示词的专注智能体
3. 持久记忆（Persistent Memory）-- 跨会话存续的文件系统支撑的研究文档
4. 结构化执行（Structured Execution）-- 明确的阶段（研究 -> 计划 -> 执行 -> 验证），配合人工审查门控

**来自 harness-engineering.ai**（https://harness-engineering.ai/blog/agent-harness-complete-guide/）的六大核心组件，分为两层：
- 基础层（Foundation Layer）：上下文工程（Context Engineering）、工具编排（Tool Orchestration）、状态与记忆管理（State and Memory Management）
- 安全层（Safety Layer）：验证与安全（Verification and Safety）、人机协同控制（Human-in-the-Loop Controls）、生命周期管理（Lifecycle Management）

**来自 parallel.ai**（https://parallel.ai/articles/what-is-an-agent-harness）的六大主要组件：
1. 工具集成层（Tool Integration Layer）
2. 记忆与状态管理（Memory and State Management）
3. 上下文工程与提示词管理（Context Engineering & Prompt Management）
4. 规划与分解（Planning and Decomposition）
5. 验证与护栏（Verification and Guardrails）
6. 模块化与可扩展性（Modularity and Extensibility）

**来自 firecrawl.dev**（https://www.firecrawl.dev/blog/what-is-an-agent-harness）的核心组件：
1. 工具集成层（Tool Integration Layer）
2. 记忆与状态管理（Memory and State Management）
3. 上下文工程与压缩（Context Engineering and Compression）
4. 验证与护栏（Verification and Guardrails）

**来自 nxcode.io**（https://www.nxcode.io/resources/news/harness-engineering-complete-guide-ai-agent-codex-2026）的三大基础支柱：
1. 上下文工程（Context Engineering）
2. 架构约束（Architectural Constraints）
3. 熵管理（Entropy Management）

渐进式披露（Progressive Disclosure）在 HumanLayer 文章（https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents）中作为 Skills 的关键概念被重点提及——"智能体仅在需要时访问知识（agents access knowledge only when needed）"。自验证（Self-verification）在同一文章中以"反压机制（back-pressure mechanisms）"的形式出现。长时运行支持架构（Long-running support architecture）在 parallel.ai 文章的"长期任务管理（Long-Horizon Task Management）"部分有所讨论。反馈循环系统（Feedback loop systems）是 GTCode 文章中关于 CI 作为驾驭和迭代改进周期讨论的核心。

---

## 6. 驾驭工程如何改变软件工程师的角色

多个来源在一个根本性的角色转变上达成共识：

**来自 nxcode.io：**

> "Traditional engineering roles shift from code authorship toward architecture design, specification writing, observability implementation, and rapid iteration on harness configurations."
>
> 传统工程角色从代码编写转向架构设计、规范撰写、可观测性实现以及驾驭配置的快速迭代。

**来自 gtcode.com**（https://gtcode.com/articles/harness-engineering/）：

> "Engineers shift from code authors to systems designers, building constraints, feedback loops, documentation structures, and lifecycle tooling."
>
> 工程师从代码作者转变为系统设计者，构建约束、反馈循环、文档结构和生命周期工具。

文章详细描述了新的投入优先级层次：首先是文档基础设施，然后是机械化架构规则编码，再是面向智能体的应用可读性，最后是自动化技术债务管理。

**来自 ignorance.ai**（https://www.ignorance.ai/p/the-emerging-harness-engineering）：工程师的工作分为两部分：（1）构建环境（驾驭工程）和（2）管理工作（智能体编排）。

**来自 Kief Morris 在 martinfowler.com 的文章**（https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html）：三种定位模式——"人在回路外（Humans Outside the Loop）"（随性编码，vibe coding）、"人在回路中（Humans In the Loop）"（微观管理瓶颈）以及推荐的"人在回路上（Humans On the Loop）"，即人类设计和管理引导智能体行为的驾驭。这代表着工程师是控制系统的设计者，而非直接的代码作者。

**来自 HumanLayer 文章：** 核心洞察是：

> "The model is probably fine. It's just a skill issue."
>
> 模型可能没问题。这只是技能问题。

——这表明工程挑战已经从编写代码转移到配置智能体环境。

**来自 Bockeler 的"开发者技能的角色"文章：** 开发者的专业技能对于识别架构模式、理解技术债务影响以及做出务实权衡仍然至关重要——但机制从编写代码转变为审查、引导和配置。

---

## 7. 驾驭工程的批评与局限性

**来自 Andrew Maynard 在 futureofbeinghuman.com 的文章**（https://www.futureofbeinghuman.com/p/what-we-miss-when-we-talk-about-ai-harnesses）：三项根本性批评：
1. **控制者与被控制者的虚假分离** -- 该隐喻假设人类指挥而 AI 执行，忽略了 AI 日益增强的操作判断能力
2. **能力而无转变** -- 该框架假设用户在使用后不会改变；Maynard 认为转变是高级 AI 交互的内在特性
3. **工具化框定** -- "只是工具"的叙事在 AI 自主性日益增强的情况下仍然存在。哲学家 Tobias Rees 将其形容为"对人类例外论的怀旧（nostalgia for human exceptionalism）"

**来自 Bockeler（martinfowler.com）：** "控制幻觉（Illusion of Control）"——尽管使用了"工程"这一术语，执行仍依赖于 LLM 的解释。上下文工程提高了有效性概率，但无法保证结果。她还指出了 OpenAI 框架中功能和行为验证的缺失。

**来自 HumanLayer（humanlayer.dev）：**
- 苏黎世联邦理工学院（ETH Zurich）的一项研究发现，LLM 生成的 AGENTS.md 文件使性能*下降*了 20% 以上，而人工编写的仅提升了约 4%
- 长上下文模型并未解决根本问题——更大的上下文意味着更大的草堆（大海捞针问题依然存在）
- 在约 168K token 的上下文窗口中，性能在上下文利用率达到约 40% 时开始下降
- 对驾驭的过度拟合：Codex 模型与其 `apply_patch` 工具紧密耦合
- 无效的做法：预先设计理想配置、"以防万一"安装数十个 Skills/服务器、每次会话运行完整测试套件、微观优化工具访问

**来自 ignorance.ai：** 剩余挑战包括防止难以维护的杂乱代码堆积、大规模验证、在缺乏架构约束的棕地（brownfield）代码库中进行改造，以及需要大量前期投入的文化采纳。

**来自 Bockeler：** 将驾驭改造到遗留代码库上可能不值得，类似于对未维护的代码运行静态分析然后"淹没在告警中"。五个月的投入时间线表明这不是一个快速启动的方法。

**来自 gtcode.com：** 未解决的问题包括：在持续智能体运行下的长期架构一致性、模型能力曲线和驾驭组件的过时、人类判断在哪里最有效地复合增值，以及超出特定仓库结构的通用性。

---

## 8. 支持驾驭工程的工具和框架

**指令/配置文件：**
- **CLAUDE.md** -- Claude Code 的项目约定文件，在会话开始时始终加载。用于包管理器偏好、环境设置、重构策略。
- **AGENTS.md** -- 由 OpenAI Codex、Amp、Jules、Cursor 和 Factory 协作开发的新兴标准。对 2,500 多个仓库的 GitHub 分析确定了最佳实践：命令靠前、代码示例、明确边界、精确的技术栈描述。OpenAI 的实现每个子系统使用 88 个 AGENTS.md 文件。
- **.github/copilot-instructions** -- GitHub Copilot 的等效指令机制。
- **Cursor Rule Files** -- 作用域限定到特定目录和文件模式；Stripe 为 Minions 使用此格式。
- **Windsurf** -- 通过自定义工作流支持指令共享。

**智能体平台：**
- **Claude Code** -- 完整的驾驭生态系统：CLAUDE.md、Rules、Skills、Subagents、MCP Servers、Hooks、Plugins。Skills 实现渐进式披露。Hooks 提供生命周期触发的脚本。
- **OpenAI Codex** -- 基于云的执行环境，配备 AGENTS.md、显式权限、基于 PR 的反馈循环。
- **Cursor** -- IDE 集成，支持规则文件和智能体能力。
- **Goose（Block/Square）** -- 开源编码智能体；Stripe 为其 Minions 系统分叉了该项目。
- **Roo Code、Kilo Code** -- 支持子智能体和多种操作模式。
- **Amp** -- 支持 30 分钟以上长会话的深度模式；Mitchell Hashimoto 偏好使用。

**基础设施工具：**
- **模型上下文协议（Model Context Protocol, MCP）** -- 向智能体暴露工具和 API 的标准。Stripe 的 "Toolshed" 托管约 500 个工具。
- **Devboxes** -- 隔离的执行环境（Stripe 在 AWS EC2 上的方案）。
- **预提交钩子（Pre-commit hooks）** -- 在智能体提交前进行确定性验证。
- **自定义检查工具（Custom linters）** -- 架构约束的机械化强制执行。
- **ArchUnit** -- Bockeler 工作中引用的结构测试框架。
- **OpenRewrite** -- 用于 AI 过度杀伤场景的确定性代码修改工具（codemod）。

**框架和 SDK：**
- **Anthropic Claude Agent SDK** -- 通用智能体驾驭，具备自动会话压缩和工具使用能力。
- **LangChain DeepAgents** -- "内置了默认提示词、工具处理、规划工具、文件系统访问等功能。"
- **Firecrawl** -- Web 访问层，提供搜索、抓取/爬取和浏览器/智能体提取原语。

**可观测性与验证：**
- **Chrome DevTools Protocol** -- 实现 UI 驱动、截图、DOM 快照，用于智能体验证。
- **Vector/Victoria Logs/Metrics** -- 用于智能体驱动验证的临时可观测性栈。
- **分布式追踪（Distributed tracing）** -- 可查询的追踪信息，用于提升智能体可读性。
- **CI 作为驾驭（CI-as-harness）** -- 使用现有 CI/CD 流水线作为主要反馈机制。

**关键指标：** 竞争优势已经转移——"模型是商品化的，驾驭才是护城河（the model is commodity. The harness is moat）。"使用相同模型的团队，仅因驾驭质量的差异，任务完成率就存在 40 个百分点的差距（来自 harness-engineering.ai）。
