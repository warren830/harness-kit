# Research: Mitchell Hashimoto and Harness Engineering

## Source

**"My AI Adoption Journey"** by Mitchell Hashimoto, published **February 5, 2026**
URL: https://mitchellh.com/writing/my-ai-adoption-journey

This is not a standalone article about "Harness Engineering" -- the concept is introduced as **Step 5** in a six-step framework describing Hashimoto's progressive adoption of AI coding agents. He explicitly notes the post was "fully written by hand, in my own words" and that he has "no skin in the game" (does not work for, invest in, or advise any AI companies).

---

## Hashimoto's Definition of Harness Engineering (verbatim quotes)

The core definition, quoted directly from the article:

> "I don't know if there is a broad industry-accepted term for this yet, but I've grown to calling this **'harness engineering.'** It is the idea that anytime you find an agent makes a mistake, you take the time to engineer a solution such that the agent never makes that mistake again. I don't need to invent any new terms here; if another one exists, I'll jump on the bandwagon."

The framing sentence:

> "At risk of stating the obvious: agents are much more efficient when they produce the right result the first time, or at worst produce a result that requires minimal touch-ups. The most sure-fire way to achieve this is to give the agent fast, high quality tools to automatically tell it when it is wrong."

---

## The Two Forms of Harness Engineering

Hashimoto defines two concrete mechanisms:

**1. Better implicit prompting (AGENTS.md)**

> "For simple things, like the agent repeatedly running the wrong commands or finding the wrong APIs, update the `AGENTS.md` (or equivalent)."

He links to a real-world example: the Ghostty project's `src/inspector/AGENTS.md` file at https://github.com/ghostty-org/ghostty/blob/ca07f8c3f775fe437d46722db80a755c2b6e6399/src/inspector/AGENTS.md

That file contains four lines, each addressing a specific observed agent failure:
- Points agents to `dcimgui.h` in `.zig-cache` for the full C API (instead of hallucinating APIs)
- Points agents to the imgui demo source for widget examples
- Tells agents to use `-Demit-macos-app=false` on macOS builds to verify API usage
- States "There are no unit tests in this package" (preventing agents from trying to run nonexistent tests)

He emphasizes: **"Each line in that file is based on a bad agent behavior, and it almost completely resolved them all."**

**2. Actual, programmed tools**

> "For example, scripts to take screenshots, run filtered tests, etc etc. This is usually paired with an AGENTS.md change to let it know about this existing."

---

## His Current Practice (at time of writing)

> "**This is where I'm at today.** I'm making an earnest effort whenever I see an agent do a Bad Thing to prevent it from ever doing that bad thing again. Or, conversely, I'm making an earnest effort for agents to be able to verify they're doing a Good Thing."

---

## How It Relates to Prompt Engineering / Context Engineering

Hashimoto does **not** explicitly draw a distinction between "harness engineering" vs. "prompt engineering" vs. "context engineering" in this article. He does not use the terms "prompt engineering" or "context engineering" at all. His framing is purely practical: harness engineering is about building infrastructure (documentation files + programmatic tools) that prevents repeated agent failures, rather than crafting better prompts per se. The emphasis is on **engineering the environment around the agent** -- the "harness" -- not on engineering the prompt itself.

The concept is closer to what some call "context engineering" (shaping the agent's environment, tools, and information) but Hashimoto's specific framing is reactive/iterative: every time you observe an agent mistake, you engineer a permanent fix into the harness.

---

## The Full Six-Step Framework (for context)

The harness engineering concept sits within Hashimoto's broader AI adoption journey:

1. **Drop the Chatbot** -- Use agents (LLMs that invoke external behavior in a loop), not chat interfaces. Minimum capabilities: read files, execute programs, make HTTP requests.

2. **Reproduce Your Own Work** -- Force yourself to redo manual commits with agents. Key discoveries: break tasks into clear segments; split planning vs. execution sessions; give agents ways to verify their own work. Also learn when *not* to use agents.

3. **End-of-Day Agents** -- Block out last 30 minutes of the day to kick off agents for: deep research, parallel exploration of vague ideas, issue/PR triage (reports only, no agent responses). Creates a "warm start" for the next morning.

4. **Outsource the Slam Dunks** -- Delegate high-confidence tasks to background agents while doing deep manual work. Critical advice: **"turn off agent desktop notifications"** -- context switching is expensive; you should control when you check the agent, not the other way around. He references the Anthropic skill formation paper, arguing you trade off skill formation in delegated tasks while continuing to form skills in manual tasks.

5. **Engineer the Harness** -- (detailed above)

6. **Always Have an Agent Running** -- Ask yourself "is there something an agent could be doing for me right now?" He mentions using Amp's deep mode (GPT-5.2-Codex) which takes 30+ minutes but produces good results. Currently achieves 10-20% of working day with a background agent. Explicitly: **"I don't want to run agents for the sake of running agents."**

---

## Key Quotes from Across the Article

On his initial skepticism and the "oh wow" moment:
> "While I was still a heavy AI skeptic, my first 'oh wow' moment was pasting a screenshot of Zed's command palette into Gemini, asking it to reproduce it with SwiftUI, and being truly flabbergasted that it did it *very well*."

On the learning process:
> "Instead of giving up, I **forced myself to reproduce all my manual commits with agentic ones.** I literally did the work twice."

On knowing when not to use agents:
> "The negative space here is worth reiterating: part of the efficiency gains here were understanding when *not* to reach for an agent."

On his relationship with AI agents:
> "babysitting my kind of stupid and yet mysteriously productive robot friend"

On the tool he uses: He specifically names **Claude Code** as the agent he adopted in Step 2.

---

## Footnotes from the Article

1. "Modern coding models like Opus and Codex are specifically trained to bias towards using tools compared to conversational models."
2. "Due to the rapid pace of innovation in models, I have to constantly revisit my priors on this one."
3. "The skill formation issues particularly in juniors without a strong grasp of fundamentals deeply worries me, however."
4. "I don't work for, invest in, or advise any AI companies."
