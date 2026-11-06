# skills

My agent skills for Claude Code and Codex. Several are adapted from
[tstack](https://github.com/t3dotgg/tstack) by Theo Browne (MIT). `standards`
borrows its coupling and special-case rules from caldoai's
[untangle-codebase](https://github.com/caldoai/skills/blob/main/skills/untangle-codebase/SKILL.md) (MIT).

| Skill | Say | What it does |
|---|---|---|
| `standards` | (automatic) | Code quality rules for writing, simplifying, reviewing, testing, and debugging code. Every other skill applies it. Includes the `tdd` and `diagnosing-bugs` guides. |
| `design` | (automatic) | UI design, polish, motion, and landing pages. Routes to the guides in `skills/design/guides`. |
| `full-send` | "full send" | Takes a change to a merged PR with nobody watching. |
| `full-stop` | "full stop" | Same as `full-send`, but stops when the PR is ready for me to merge. |
| `review-loop` | "review loop", "sol loop", "council" | Reviews with other models in a loop until a stop condition, and pushes back on overreach. |
| `file-pr` | "file a PR" | Files a PR that leads with the problem and is easy to read. |
| `pr-comments` | (automatic) | Writes and attributes comments posted on my behalf. |
| `babysit-pr` | "babysit" | Watches a PR through CI and review bots, and fixes real findings. |
| `modernize` | "modernize" | Rebases an old PR and decides whether it should still exist. |
| `takeover` | "take over" | Finishes someone else's PR, branch, or thread, and keeps their credit. |

Default reviewers: GPT Sol 6.1. Council: Claude Opus 5.5 and GPT Sol 6.1.

## Guides

`skills/standards/guides` and `skills/design/guides` hold copies of other
people's skills, renamed from `SKILL.md` to `GUIDE.md` so they install only as
part of their parent skill:

- `tdd` and `diagnosing-bugs` (in `standards`) from
  [mattpocock/skills](https://github.com/mattpocock/skills) (MIT)
- `frontend-design` (in `design`) from [anthropics/skills](https://github.com/anthropics/skills) (Apache-2.0)
- `emil-design-eng`, `animate`, `animate-expo`, `review-animations`,
  `improve-animations`, `find-animation-opportunities`, and `break-ui` (in
  `design`) from
  Emil Kowalski's [skill](https://github.com/emilkowalski/skill) and
  [skills](https://github.com/emilkowalski/skills) repos (MIT)

Each guide keeps its upstream license. To refresh them from upstream:

```bash
./scripts/sync-guides.sh
```

[taste-skill](https://github.com/leonxlnx/taste-skill) (MIT) is too large to
copy, so `design` clones it into `~/.cache/taste-skill` when it needs it.

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
