---
name: stacked-prs
description: GitHub's native stacked pull requests and the `gh stack` CLI. Covers creating a stack, editing a layer, restacking after a merge, and merging part or all of a stack. Use whenever the user mentions stacked PRs, a PR stack, GitHub stacks, dependent PRs, or `gh stack`, when splitting work into reviewable layers, and whenever a PR's base is another PR's branch.
---

# Stacked PRs

A stack is a chain of PRs where each PR's base is the branch of the PR below
it, so each PR shows only its own layer. GitHub supports stacks natively. It
runs CI on every layer, merges any bottom slice in one step, and rebases and
retargets the PRs above after a merge, squash merges included. Always use
native stacks through the `gh stack` extension
(`gh extension install github/gh-stack`). Don't chain PRs by hand.

Use v0.3.0 or later. Check with `gh extension list`, and run
`gh extension upgrade stack` if it's older. Before v0.3.0, `sync` and
`rebase` replayed already-merged commits when a local branch was out of date,
which caused conflicts in files the layer never touched.

Rebasing a stack, and the lease-protected force-pushes that `gh stack push`
and `gh stack sync` do, are pre-authorized.

## Agent rules

`gh stack` opens prompts or a full-screen UI when it thinks it has a terminal,
and then hangs. So:

- Run `gh stack view --json`, never bare `view`.
- Run `gh stack submit --auto --open`. That opens ready PRs, not drafts.
- Always pass explicit arguments to `init`, `add`, and `checkout`.
- Never run `gh stack modify` or `gh stack switch`. They have no
  non-interactive mode.
- Never use `gh pr merge` or `gh pr edit --base` on a stacked PR.
- Exit codes: 3 is a rebase conflict, 7 is a rebase already in progress, 8 is
  locked (retry in a few seconds), and 9 means stacks aren't enabled on the
  repo (see "Fallback").
- `gh stack <command> --help` is authoritative. `gh stack help <command>`
  prints the top-level help instead.
- Turn on `git config rerere.enabled true` so conflict resolutions get reused
  across layers.
- Never pass `--accept-base-change` on your own. `sync` and `rebase` ask for it
  only when GitHub retargeted the stack and the old base never merged, so
  accepting drops commits that never landed. Ask the user first.

## Is it a native stack?

```sh
gh api graphql -f query='{ repository(owner: "<o>", name: "<r>") {
  pullRequest(number: <n>) { stack { number size } stackEntry { position } } } }'
```

If `stack` is null but the PR's base is another PR's branch, it's a plain
chain. Link it bottom to top with `gh stack link --base <trunk> <bottom>
... <top>`, then query again. If the PRs have different authors, ask first.

## Create

1. Plan the layers before writing code. Put one concern in each layer, with
   foundations at the bottom. Follow the repo's branch naming.
2. `gh stack init <first-branch>`, then commit. For each next layer,
   `gh stack add <branch>`, then commit. Stage files deliberately so each
   change lands in the layer it belongs to.
3. `gh stack submit --auto --open`. It generates the titles and bodies, so
   rewrite each one with `pr-writing` (`gh pr edit`).

To change a lower layer, check it out (`gh stack checkout <branch>`), commit,
then run `gh stack rebase --upstack` and `gh stack push`. Never commit a lower
layer's change on a higher branch.

## Keep it current

Run `gh stack sync` after any merge, or when the trunk moves. It fetches,
detects squash merges, replays the remaining layers with `--onto`, and pushes.

- **Conflict (exit 3):** sync has already restored every branch. Run
  `gh stack rebase`, resolve, `git add`, then `gh stack rebase --continue` and
  `gh stack push`.
- **"Sync aborted" with exit 0:** nothing happened, because the local and
  remote stacks diverged. Run `gh stack unstack --local`, then
  `gh stack checkout <stack>`.
- **A false conflict after a squash merge:** GitHub doesn't always rebase the
  next PR. It shows "Resolve conflicts" and no "Rebase stack" button.
  `gh stack sync` fixes it.
- **Conflicts in files the layer never touched:** sync is replaying merged
  commits. Check the version first. If it still happens on v0.3.0 or later,
  run `gh stack rebase --abort` and rebase each remaining layer by hand onto
  its updated parent:
  `git rebase --onto <parent> <old parent head> <branch>`, then
  `git push --force-with-lease=<branch>:<its head before the rebase>`.

After any rewrite, run the checks for every changed layer before you call it
ready. In a worktree, `rebase` and `sync` update the clean worktrees and skip
the dirty ones.

## Merge

`gh stack merge <highest PR to land> --yes` merges that PR and every unmerged
PR below it, all or nothing. Pass the stack number instead to merge the whole
stack. Pass the repo's method (`--squash` in a squash-only repo). With a merge
queue, the stack is queued and the queue picks the method.

- **Before:** every selected PR is open, not a draft, green, and approved under
  the repo's rules. Check each layer on its own.
- **After:** confirm each one shows `MERGED`, run `gh stack sync --prune`, then
  check CI on the layers that remain. Don't delete branches or retarget PRs by
  hand.
- **Sync right away, even if the next PR looks fine.** GitHub retargets it to
  the trunk but doesn't always rebase it, so its diff can show the merged
  layers' changes again. Don't hand-build merge commits to avoid sync's
  force-push: they break the linear chain `gh stack merge` needs ("not a
  linear descendant").

## Fallback: stacks unavailable (exit 9)

Restack a plain chain after a squash merge:

1. Get the merged PR's final head: `gh pr view <n> --json headRefOid`.
2. `git rebase --onto origin/<base> <final head> <branch>`.
3. `gh pr edit <n> --base <base>`.
4. `git push --force-with-lease=<branch>:<its head before the rebase>`.
5. Repeat up the stack, onto the branch below.

Merge one PR at a time from the bottom. Never merge a PR whose base is still
another PR's branch: it merges into that branch.
