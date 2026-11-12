---
name: retro
description: Run a retrospective on a coding session and suggest changes to the agent's environment that would improve future sessions.
disable-model-invocation: true
---

# Retro

Find changes to the agent's **environment** that would make future sessions
faster or less error-prone. The environment is the repo's checks and
instruction files, the user's skills, and the tools and access the agent
has. Fixing the session's code is a different job.

## 1. Read the session

Use the session the user names, or the current one if they name none. For
an older session, find its log on this machine (Claude Code:
`~/.claude/projects/<project>/*.jsonl`, Codex: `~/.codex/sessions/`). In T3
Code, read the thread with `t3_thread_read`. Read the primary sources: the
transcript, the diff, CI runs, and review comments.

Look for what cost real time or caused a real bug: wrong turns, mistakes a
reviewer or the user caught, repeated failures, slow steps, and corrections
from the user.

## 2. Find where each fix belongs

- **Automated checks.** Could a lint rule, type, test, pre-commit hook, or
  CI job have caught the mistake? Read the repo's check commands and CI
  first. A check that exists but isn't wired up, or is broken, is the
  finding. So is a repo with no guardrail at all (no hook or CI job running
  lint, typecheck, and tests). When a mistake is mechanical (a banned API,
  an import shape, a file location), propose a check, not a written rule.
- **Review rules.** Should the reviewer have caught it? Judgement calls that
  no check can enforce go in the review rules: the repo's standards file if
  it has one, otherwise the `standards` skill. The reviewer has the least
  context pressure, so rules belong there, not in instructions the
  implementing agent has to hold.
- **Navigation.** Did the agent take long to find a file or fact? A
  one-line pointer in the repo's `AGENTS.md` or `CLAUDE.md`, or in a doc,
  may fix it.
- **Instructions.** Is an instruction in the repo's `AGENTS.md` or
  `CLAUDE.md`, the global instructions, or a skill missing, wrong, or
  ignored? Is one a no-op, or long text that belongs in a check, a review
  rule, or a doc? These files load into every session, so keep them short.
- **Tools.** Was a tool call expensive or slow every time? Would a script, a
  narrower command, or shorter output make it cheap?
- **Information access.** Did the agent lack something it needed, like
  logs, a dev server's output, or read-only access to a service?

For the user's skills and global instructions, propose the change in their
source repo, not the installed copies. An update overwrites those.

## 3. Report

Rank the findings by how much fixing them would help future work, most
first. Leave out anything that cost little. For each one, give:

- what happened, and what it cost;
- the single change that would prevent it, and the file it goes in.

Don't apply the changes. The user picks which to make.
