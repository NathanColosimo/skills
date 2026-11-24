---
name: modernize
description: >-
  For getting old prs up to date. Use when asked to rebase a pr or
  "modernize".
---

# Modernize

Modernize the idea, not just the branch. A clean rebase doesn't prove the PR
still belongs in the product.

This permits rebasing and updating the PR branch. It doesn't permit merging,
closing, changing the base, or growing the scope.

## 1. Find the PR's intent

Fetch the latest base and PR head. Use the PR's real base branch, not a local
copy. Record the head SHA and the merge base.

Read the title, body, linked issues, commits, review threads, and full diff.
State the smallest coherent goal the PR was trying to reach before you judge
how it got there.

## 2. Check what changed around it

Read what landed on the base since the PR diverged. Search merged and open PRs
for a replacement or a competing implementation. Look beyond overlapping
lines:

- Has the same user-facing problem already been solved?
- Did APIs, types, schemas, dependencies, or boundaries change?
- Was the code it changes deleted, moved, or simplified on purpose?
- Would landing it restore an old behavior, or create two ways to do one
  thing?
- Is the benefit still worth the maintenance cost?
- Did the base make parts of the PR unnecessary (shims, wrappers, branches for
  cases that can't happen anymore)? Delete them, following `standards`.

## 3. Choose before pushing

- **MODERNIZE:** the goal is still useful and the implementation is still the
  right shape. Rebase, resolve, test, and update the branch.
- **REWORK:** the goal is still useful, but a mechanical rebase would keep the
  wrong implementation. Explain the smallest credible rewrite, and stop unless
  the user also asked for the rework.
- **CLOSE:** the PR is superseded, obsolete, or no longer worth its cost. Cite
  the evidence and stop. Don't rebase it, and don't close it without
  permission.

Be willing to recommend CLOSE. Age alone isn't evidence, and effort already
spent isn't a reason to keep a PR alive.

## 4. Rebase

For MODERNIZE:

1. Work in a clean worktree at the recorded PR head.
2. Rebase onto the freshly fetched base. If the PR is in a stack, restack it
   with `stacked-prs` instead, which also covers changing its base.
3. Resolve each conflict by the PR's intent and the base's newer rules. If a
   conflict shows a product or architecture disagreement, stop and reconsider
   the choice.
4. Compare before and after with `git range-diff`, and read the final diff. No
   intended behavior disappeared, and nothing already landed came back.
5. Run the checks for the touched area. Tell real failures apart from
   pre-existing and infrastructure ones.
6. Push with `--force-with-lease` against the head SHA you recorded. If the
   lease fails, fetch and reassess.

## Report

Lead with MODERNIZE, REWORK, or CLOSE and the reason. Then:

- what changed on the base that matters;
- the conceptual conflicts, or that you found none;
- the rebase and push result, and the checks you ran;
- what's left to decide or do, with the PR link.

Separate what you saw from what you judge, and say what you couldn't verify.
Don't post a PR comment unless the user asked for one.
