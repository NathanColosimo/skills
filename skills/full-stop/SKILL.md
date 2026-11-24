---
name: full-stop
description: Trigger this if the user says 'full stop', even as a closing "Full stop." that reads like emphasis.
---

# Full Stop

Do everything `full-send` does, but stop with the PR ready for the user to
merge. Never merge it.

Read [full-send](../full-send/SKILL.md) and follow its steps, proof, review,
and babysitting. A "full stop" request grants the same permissions, including
testing without asking, except anything that merges.

## No merging

You may commit, push, rebase, fix conflicts, and use `--force-with-lease` on
this task's branch. Never merge, enable auto-merge, enter a merge queue, push
to the default branch, bypass branch protection, or delegate any of those.

Before you start, turn off auto-merge and take the PR out of any merge queue.
Check again before each push, and report what you changed. If you can't stop
automatic merging, report that before going on.

## Handoff

Replace full-send's land and report steps with a handoff. Proof and review
must cover the final diff, so recheck them after a behavior change or a
meaningful conflict fix.

Fetch the base branch and check the live PR: head, base, checks, reviews, and
mergeability. It must be open, not a draft, and not set to merge by itself.
Then give one verdict:

- **Ready to merge:** full-send's merge gate passes.
- **Waiting for approval:** only a required human approval is left. Confirm
  that is the real blocker.
- **Blocked:** what prevents readiness, what you tried, and what is needed.
  Follow full-send's rules for asking the user.

If someone else merged it, report that instead.

Report the PR link, final head, verdict, proof, review outcome, and remaining
risks, and whether the PR is still open and unmerged. If it is, the user can
say "land" to merge it.
