---
name: retro
description: Run a retrospective on a coding session and suggest changes to the agent's environment that would improve future sessions.
disable-model-invocation: true
---

# Retro

Find changes to the agent's **environment** that would make future sessions
faster or less error-prone: the repo's checks and instruction files, the
user's skills, and the agent's tools and access.

## 1. Read the session

Use the session the user names, or the current one. For an older session, find
its log on this machine (Claude Code: `~/.claude/projects/<project>/*.jsonl`,
Codex: `~/.codex/sessions/`), or in T3 Code read the thread with
`t3_thread_read`. Read the primary sources: the transcript, the diff, CI runs,
and review comments.

Look for what cost real time or caused a real bug: wrong turns, mistakes a
reviewer or the user caught, repeated failures, slow steps, and corrections
from the user.

## 2. Find where each fix belongs

- **A check.** Could a lint rule, type, test, pre-commit hook, or CI job have
  caught it? Read the repo's check commands and CI first. A check that exists
  but isn't wired up, or doesn't block, is the finding. So is a repo with no
  guardrail at all. A mechanical mistake (a banned API, an import shape, a
  file location) gets a check, not a written rule.
- **A review rule.** Judgment calls no check can enforce go in the repo's
  standards file, or the `standards` skill if it has none. The reviewer has
  the least context pressure, so rules belong there, not in instructions the
  implementing agent has to hold.
- **A pointer.** If the agent took long to find a file or fact, one line in
  the repo's `AGENTS.md` or `CLAUDE.md` may fix it.
- **An instruction.** Is one in the repo's instruction files, the global
  instructions, or a skill missing, wrong, or ignored? Is one a no-op, or long
  text that belongs in a check, a review rule, or a doc? These files load into
  every session, so keep them short.
- **A tool.** Was a tool call slow or expensive every time? A script, a
  narrower command, or shorter output may make it cheap.
- **Access.** Did the agent lack something it needed, like logs, a dev
  server's output, or read-only access to a service?

Propose changes to the user's skills and global instructions in their source
repo, not the installed copies. An update overwrites those.

## 3. Report

Rank the findings by how much fixing them would help, most first, and leave
out anything that cost little. For each one, give:

- what happened, and what it cost;
- the one change that would prevent it, and the file it goes in.

Don't apply the changes. The user picks which to make.
