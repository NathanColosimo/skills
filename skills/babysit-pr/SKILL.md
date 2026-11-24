---
name: babysit-pr
description: Monitor a pull request through review and CI. Use when the user asks to monitor, watch, or babysit a PR.
---

# Babysit PR

Watch a PR until it is ready: checks green, review bots finished, every
finding answered.

## Waiting

Use one watcher per PR: `watch_pull_request` in T3 Code, `pr-wait` everywhere
else. Never run both, and never write your own polling or `sleep` loop. Every
watcher on a GitHub account shares one rate limit.

When an event needs no action, end your turn without a message. Never post or
say "still waiting".

### In T3 Code: `watch_pull_request`

Handle the existing checks and comments first. Then call `watch_pull_request`
and end your turn. T3 Code wakes you when a check fails, the required checks
pass, someone comments or reviews, or the branch conflicts.

- **Only the thread that owns the PR watches it.** A delegated child task
  never calls `watch_pull_request`.
- **On a wake, check readiness yourself.**
- **Unwatch before you stop** (ready, blocked, or asking the user a
  question), with `unwatch_pull_request`. A watched thread stays in Working
  and out of the user's inbox. A merge or close ends the watch by itself.
- **"Stopped watching, could not read it"** usually means the rate limit is
  used up. Run `gh api rate_limit --jq .resources.graphql`. If `remaining` is
  near 0, wait for `reset` with one background command, then watch again.

### Everywhere else: `pr-wait`

Run `scripts/pr-wait` from this skill's directory, by its absolute path:

```bash
pr-wait <pr> [--repo owner/name] [--until ready|green|any-change]
```

It prints one line per real event. It exits 0 when the `--until` condition is
met or the PR merges, 1 when it needs you (a required check failed, conflicts,
unresolved threads, PR closed), and 2 on bad input.

- `ready` (default): required checks green, no unresolved threads, and not
  behind the base.
- `green`: required checks only.
- `any-change`: exit on the first event.

In Claude Code, run it with the Monitor tool (`timeout_ms: 3600000`) so each
line wakes you. Otherwise run it as one long command.

Start it again after you push, after you handle an exit 1, and after a resume.
It remembers what it already reported. If it says another pid already watches
the PR, don't start a second one. Kill the old one only if its events don't
reach you.

### When GraphQL is rate limited

`gh pr view` and `gh pr checks` use GraphQL. The REST limit is separate and
usually still has room: read a PR with `gh api repos/<owner>/<repo>/pulls/<n>`
and its checks with `gh api repos/<owner>/<repo>/commits/<sha>/check-runs`.

## Findings

Act only on checks and comments newer than the latest push. Check every bot
finding against the code before you change anything.

- **Real finding or CI failure:** fix it. Prefer the fix that deletes or
  narrows code. Tell a failure in the repo apart from an infrastructure flake.
- **Wrong, or not worth doing:** reply with a written reason and resolve the
  thread. Decline anything that would break `standards`, such as a shim or a
  branch for a case that can't happen, and cite the rule.
- **Not needed for the user's goal:** decline it and list it as a follow-up.
  Bots grow a PR one cheap-looking fix at a time: unneeded tests, guards for
  edge cases that don't matter, extra compatibility, small performance costs.

Write every reply with `pr-writing`.

## Base branch

- If the PR is in a stack (its base is another PR's branch), follow
  `stacked-prs`.
- Rebase when the base moves under the PR. `pr-wait` reports base commits that
  touch this PR's files, and when the PR becomes BEHIND or DIRTY.
  `watch_pull_request` reports conflicts only, so check for BEHIND yourself.
- The PR isn't ready while it is BEHIND or DIRTY, or while base commits that
  landed after the last green run touch its files. Rebase, push, and wait for
  green again.
- If another PR makes this one obsolete, stop, tell the user, and ask before
  closing it.

Stop when `pr-wait` exits 0, or in T3 Code when `full-send`'s merge gate
passes on the latest head. Report that the PR is ready.
