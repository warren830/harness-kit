# 研究：Mitchell Hashimoto 与驾驭工程（Harness Engineering）

## 来源

**"My AI Adoption Journey"**（我的 AI 采用之旅），作者 Mitchell Hashimoto，发表于 **2026 年 2 月 5 日**
URL: https://mitchellh.com/writing/my-ai-adoption-journey

这并非一篇专门论述"驾驭工程（Harness Engineering）"的独立文章——该概念是作为 Hashimoto 渐进式采用 AI 编程代理（coding agents）六步框架中的**第五步**被引入的。他明确指出这篇文章"完全由本人亲手撰写，用自己的话表达"，并且他"没有任何利益关系"（不在任何 AI 公司任职、投资或担任顾问）。

---

## Hashimoto 对驾驭工程（Harness Engineering）的定义（原文引述）

核心定义，直接引用自原文：

> "I don't know if there is a broad industry-accepted term for this yet, but I've grown to calling this **'harness engineering.'** It is the idea that anytime you find an agent makes a mistake, you take the time to engineer a solution such that the agent never makes that mistake again. I don't need to invent any new terms here; if another one exists, I'll jump on the bandwagon."

中文翻译：我不知道业界是否已有广泛接受的术语，但我逐渐将其称为**"驾驭工程（harness engineering）"**。其核心理念是：每当你发现代理犯了一个错误，你就花时间去构建一个解决方案，使代理永远不再犯同样的错误。我不需要在这里发明新术语；如果已有其他术语存在，我很乐意跟随。

其框架性论述：

> "At risk of stating the obvious: agents are much more efficient when they produce the right result the first time, or at worst produce a result that requires minimal touch-ups. The most sure-fire way to achieve this is to give the agent fast, high quality tools to automatically tell it when it is wrong."

中文翻译：冒着陈述显而易见之事的风险：代理在第一次就产出正确结果时效率最高，或者退而求其次，产出的结果只需最少量的修改。实现这一目标最可靠的方式，是为代理提供快速、高质量的工具，使其能够自动得知何时出了错。

---

## 驾驭工程的两种形式

Hashimoto 定义了两种具体机制：

**1. 更好的隐式提示（implicit prompting）——AGENTS.md**

> "For simple things, like the agent repeatedly running the wrong commands or finding the wrong APIs, update the `AGENTS.md` (or equivalent)."

中文翻译：对于简单的情况，比如代理反复执行错误的命令或找到错误的 API，更新 `AGENTS.md`（或等效文件）即可。

他引用了一个真实案例：Ghostty 项目的 `src/inspector/AGENTS.md` 文件，地址为 https://github.com/ghostty-org/ghostty/blob/ca07f8c3f775fe437d46722db80a755c2b6e6399/src/inspector/AGENTS.md

该文件包含四行内容，每一行针对一个已观察到的代理失败行为：
- 引导代理到 `.zig-cache` 中的 `dcimgui.h` 以获取完整的 C API（而非幻觉生成 API）
- 引导代理查看 imgui 演示源码以获取组件示例
- 告知代理在 macOS 构建时使用 `-Demit-macos-app=false` 以验证 API 用法
- 声明"本包中没有单元测试（unit tests）"（防止代理尝试运行不存在的测试）

他强调：**"该文件中的每一行都基于一个不良的代理行为，并且几乎完全解决了所有这些问题。"**

**2. 实际的编程工具（programmed tools）**

> "For example, scripts to take screenshots, run filtered tests, etc etc. This is usually paired with an AGENTS.md change to let it know about this existing."

中文翻译：例如，用于截图的脚本、运行筛选测试的脚本等等。这通常与 AGENTS.md 的更新配合使用，以让代理知道这些工具的存在。

---

## 他目前的实践（撰文时）

> "**This is where I'm at today.** I'm making an earnest effort whenever I see an agent do a Bad Thing to prevent it from ever doing that bad thing again. Or, conversely, I'm making an earnest effort for agents to be able to verify they're doing a Good Thing."

中文翻译：**这就是我目前所处的阶段。** 每当我看到代理做了一件"坏事"，我都会认真地努力防止它再次犯同样的错误。反过来说，我也在认真地努力让代理能够验证自己正在做一件"好事"。

---

## 与提示工程（Prompt Engineering）/ 上下文工程（Context Engineering）的关系

Hashimoto 在这篇文章中**没有**明确区分"驾驭工程（harness engineering）"与"提示工程（prompt engineering）"或"上下文工程（context engineering）"。他完全没有使用"提示工程"或"上下文工程"这两个术语。他的表述纯粹是实践导向的：驾驭工程的核心是构建基础设施（文档文件 + 编程工具）来防止代理反复犯错，而非精心设计更好的提示词（prompt）本身。重点在于**围绕代理构建工程化的环境**——即"驾驭装置（harness）"——而非对提示本身进行工程化。

该概念更接近于一些人所说的"上下文工程（context engineering）"（塑造代理的环境、工具和信息），但 Hashimoto 的特定框架是反应式/迭代式的：每次观察到代理的一个错误，就将一个永久性修复方案工程化地固化到驾驭装置中。

---

## 完整六步框架（提供上下文）

驾驭工程的概念位于 Hashimoto 更广泛的 AI 采用旅程之中：

1. **摒弃聊天机器人（Drop the Chatbot）** ——使用代理（agents，即在循环中调用外部行为的 LLM），而非聊天界面。最低能力要求：读取文件、执行程序、发起 HTTP 请求。

2. **复现你自己的工作（Reproduce Your Own Work）** ——强迫自己用代理重做手动完成的提交（commits）。关键发现：将任务拆分为清晰的段落；将规划（planning）与执行（execution）会话分开；为代理提供验证自身工作的方式。同时也要学会何时*不*使用代理。

3. **一天结束时启用代理（End-of-Day Agents）** ——在一天的最后 30 分钟启动代理，用于：深度研究、并行探索模糊想法、Issue/PR 分诊（triage，仅生成报告，代理不直接回复）。这为第二天早晨创造了一个"热启动（warm start）"。

4. **外包确定性任务（Outsource the Slam Dunks）** ——在进行深度手动工作的同时，将高确信度的任务委派给后台代理。关键建议：**"关掉代理的桌面通知"**——上下文切换（context switching）代价高昂；应该由你来控制何时查看代理，而非让代理来打断你。他引用了 Anthropic 的技能形成（skill formation）论文，认为你在委派的任务中会牺牲技能形成，但在手动任务中可以继续形成技能。

5. **构建驾驭装置（Engineer the Harness）** ——（详见上文）

6. **始终让代理运行（Always Have an Agent Running）** ——问自己"现在有没有什么事情代理可以帮我做？"他提到使用 Amp 的深度模式（deep mode，GPT-5.2-Codex），该模式需要 30 分钟以上但能产出良好结果。目前工作日中有 10-20% 的时间有后台代理在运行。他明确表示：**"我不想为了运行代理而运行代理。"**

---

## 全文关键引述

关于他最初的怀疑态度和"惊叹"时刻：
> "While I was still a heavy AI skeptic, my first 'oh wow' moment was pasting a screenshot of Zed's command palette into Gemini, asking it to reproduce it with SwiftUI, and being truly flabbergasted that it did it *very well*."

中文翻译：当我还是一个重度 AI 怀疑论者时，我第一个"哇哦"时刻是将 Zed 的命令面板截图粘贴到 Gemini 中，要求它用 SwiftUI 复现，然后我真的被它做得*非常好*这一事实惊呆了。

关于学习过程：
> "Instead of giving up, I **forced myself to reproduce all my manual commits with agentic ones.** I literally did the work twice."

中文翻译：我没有放弃，而是**强迫自己用代理重做所有手动提交的工作。** 我确确实实把同样的工作做了两遍。

关于知道何时不使用代理：
> "The negative space here is worth reiterating: part of the efficiency gains here were understanding when *not* to reach for an agent."

中文翻译：这里的"留白"值得重申：效率提升的一部分来自于理解何时*不*应该求助于代理。

关于他与 AI 代理的关系：
> "babysitting my kind of stupid and yet mysteriously productive robot friend"

中文翻译：照看我那个有点蠢、却神秘地高产的机器人朋友

关于他使用的工具：他在第二步中特别指名使用了 **Claude Code** 作为其采用的代理。

---

## 文章脚注

1. "Modern coding models like Opus and Codex are specifically trained to bias towards using tools compared to conversational models."（现代编程模型如 Opus 和 Codex 经过专门训练，相比对话模型更倾向于使用工具。）
2. "Due to the rapid pace of innovation in models, I have to constantly revisit my priors on this one."（由于模型创新速度极快，我不得不不断重新审视自己在这方面的先验认知。）
3. "The skill formation issues particularly in juniors without a strong grasp of fundamentals deeply worries me, however."（然而，技能形成问题——尤其是对于基础功尚不扎实的初级开发者——让我深感担忧。）
4. "I don't work for, invest in, or advise any AI companies."（我不在任何 AI 公司任职、投资或担任顾问。）
