# skills

My agent skills for Claude Code and Codex. Many are built on other people's
work; see [Attribution](#attribution) at the end.

| Skill | Say | What it does |
|---|---|---|
| `standards` | (automatic) | Code quality rules for writing, simplifying, reviewing, testing, and debugging code. Every other skill applies it. Includes the `tdd` and `diagnosing-bugs` guides. |
| `design` | (automatic) | UI design, polish, motion, and landing pages. Routes to the guides in `skills/design/guides`. |
| `full-send` | "full send" | Takes a change to a merged PR with nobody watching. |
| `full-stop` | "full stop" | Same as `full-send`, but stops when the PR is ready for me to merge. |
| `land` | "land" | Merges a finished PR (through the merge queue if there is one), watches the deploy and production, closes related issues and PRs, and runs a short retro. |
| `review-loop` | "review loop", "sol loop", "council" | Reviews with other models in a loop until a stop condition, and pushes back on overreach. |
| `pr-writing` | "file a PR" (and automatic for comments) | Writes PR titles, descriptions, and comments: says who did what, leads with the problem, shows evidence that fits the change, and keeps private details out of public repos. |
| `babysit-pr` | "babysit" | Watches a PR through CI and review bots, and fixes real findings. |
| `modernize` | "modernize" | Rebases an old PR and decides whether it should still exist. |
| `takeover` | "take over" | Finishes someone else's PR, branch, or thread, and keeps their credit. |

Default reviewers: GPT Sol 6.1. Council: Claude Opus 5.5 and GPT Sol 6.1.

## Guides

Guides are workflows that install only as part of their parent skill, so
they don't show up as skills of their own. They're my own edited copies of
other people's skills, trimmed and rewritten. They don't sync from upstream,
and each keeps its original license.

`design` uses [taste-skill](https://github.com/leonxlnx/taste-skill) for
landing pages. It's too large to copy, so `design` clones it into
`~/.cache/taste-skill` when it needs it.

## Global instructions

`global/AGENTS.md` holds my global agent instructions: when to apply
`standards` and `pr-writing`, and how agents should format their responses.
Edit it here, then copy it to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`:

```bash
./scripts/install-global.sh
```

Run that again after pulling changes to it.

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

## Attribution

| Used in | Source | Author | License | How it's used |
| --- | --- | --- | --- | --- |
| `full-send`, `full-stop`, `modernize`, `takeover`, `babysit-pr` | [tstack](https://github.com/t3dotgg/tstack) | Theo Browne | MIT | Adapted |
| `standards` | [untangle-codebase](https://github.com/caldoai/skills/blob/main/skills/untangle-codebase/SKILL.md) | caldoai | MIT | Coupling and special-case rules |
| `standards` (`tdd`, `diagnosing-bugs` guides) | [mattpocock/skills](https://github.com/mattpocock/skills) | Matt Pocock | MIT | Edited copies |
| `standards` | [no-use-effect](https://github.com/factory-ai/factory-plugins/tree/master/plugins/typescript/skills/no-use-effect) | Factory | None stated | Ideas, rewritten |
| `standards`, `design` | [nando-skill](https://github.com/nandorojo/nando-skill) | Fernando Rojo | None stated | Ideas, rewritten |
| `design` (`frontend-design` guide) | [anthropics/skills](https://github.com/anthropics/skills) | Anthropic | Apache-2.0 | Edited copy |
| `design` (`emil-design-eng`, `animate`, `animate-expo`, `review-animations`, `improve-animations`, `find-animation-opportunities`, `break-ui` guides) | [skill](https://github.com/emilkowalski/skill), [skills](https://github.com/emilkowalski/skills) | Emil Kowalski | MIT | Edited copies |
| `design` (landing pages) | [taste-skill](https://github.com/leonxlnx/taste-skill) | leonxlnx | MIT | Fetched on demand |
| `pr-writing` | [What My Pull Requests Look Like Now](https://hugorcd.com/writing/what-my-pull-requests-look-like-now) and his `pr-writing` skill | Hugo Richard | None stated | Ideas, rewritten |
