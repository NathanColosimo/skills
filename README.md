# skills

My agent skills for Claude Code and Codex. Several are adapted from
[tstack](https://github.com/t3dotgg/tstack) by Theo Browne (MIT).

| Skill | Say | What it does |
|---|---|---|
| `standards` | (automatic) | Code quality rules for writing, simplifying, and reviewing code. Every other skill applies it. |
| `full-send` | "full send" | Takes a change to a merged PR with nobody watching. |
| `full-stop` | "full stop" | Same as `full-send`, but stops when the PR is ready for me to merge. |
| `review-loop` | "review loop", "sol loop", "council" | Reviews with other models in a loop until a stop condition, and pushes back on overreach. |
| `file-pr` | "file a PR" | Files a PR that leads with the problem and is easy to read. |
| `pr-comments` | (automatic) | Writes and attributes comments posted on my behalf. |
| `babysit-pr` | "babysit" | Watches a PR through CI and review bots, and fixes real findings. |
| `modernize` | "modernize" | Rebases an old PR and decides whether it should still exist. |
| `takeover` | "take over" | Finishes someone else's PR, branch, or thread, and keeps their credit. |

Default reviewers: GPT Sol 6.1. Council: Claude Opus 5.5 and GPT Sol 6.1.

## Install

```bash
npx skills add NathanColosimo/skills -g -a claude-code -a codex -y
```

## Update

Push changes here, then on each machine:

```bash
npx skills update -g -y
```

Edit this repo, not the installed copies. An update overwrites those.

## Requirements

- An authenticated [GitHub CLI](https://cli.github.com) (`gh`).
- `python3` for `babysit-pr`'s `pr-wait` script.
- `review-loop` needs subagents on other providers' models. T3 Code provides
  them through `delegate_task`.
