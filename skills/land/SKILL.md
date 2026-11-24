---
name: land
description: Land a finished PR. Merge it (through the merge queue if the repo has one), watch it deploy, check production, finish the follow-up chores, and run a retro when the session turned up something worth fixing. Use when the user says "land", "land it", or "land the PR", usually after full-stop or full-send. Not for landing pages; that's the design skill.
---

# Land

The user wants to come back and find the change merged, deployed, working in
production, and every leftover chore done. They are not watching, so keep
going until the work is finished or you hit something you can't fix with
confidence.

A "land" request gives you permission to:

- merge the PR, or add it to the merge queue;
- rebase the PR's branch, fix conflicts and CI failures, and push with
  `--force-with-lease`;
- comment on, and close, other PRs and issues that this PR resolves.

It doesn't cover reverting, rolling back, changing production config, or
deleting data. Ask first.

## 1. Merge

1. Find the PR (the one in this thread, or the one the user names) and check
   `full-send`'s merge gate on its latest head. If proof or review never
   happened, stop and say so.
2. Right before merging, fetch and check the PR again. Then merge with the
   repo's method: check the allowed methods and recent merged PRs. With a
   merge queue, `gh pr merge <n>` queues it. A stacked PR merges with
   `stacked-prs`. Never use `--admin` or bypass branch protection.
3. Wait with `babysit-pr`'s watcher until GitHub reports it merged.
4. If it doesn't merge, fix the obvious cause and try again:
   - a conflict with the new base: rebase and resolve it;
   - a CI failure this PR caused: fix it;
   - a flaky test or infrastructure failure: re-run it once;
   - kicked from the queue because another PR failed: queue it again.

   Prove any fix that changes behavior. Stop after three failed attempts, or
   as soon as it needs a decision you can't make with confidence, such as a
   conflict where both sides changed behavior.

## 2. Deploy

Find out how the project ships: the workflows on the default branch, GitHub
deployments (`gh api repos/<o>/<r>/deployments`), the hosting provider, and
the repo's deploy docs. If nothing deploys on merge, say so and go to step 5.

Wait for every deploy this merge starts, with a background command or a
monitor. Then confirm the new version is live: the deployed commit matches,
and the changed path works (the page loads, the endpoint answers).

## 3. Check production

Do this when only production can show the change misbehaving: performance, an
API change, a migration, auth, payments, background jobs, or anything with
real traffic. Skip it for docs, tests, and refactors with no runtime effect,
and say you skipped it.

With whatever read-only access you have (logs, traces, metrics, error
tracking), compare a window after the deploy with the same window before it:

- error rate and new error types on the changed paths;
- latency on the changed endpoints, with the numbers for a performance change;
- whether the traffic you expected actually reached the new code.

Watch long enough for real traffic to hit the change, usually 15 to 30
minutes. If you have no access, list exactly what the user should check.

## 4. When something goes wrong

If the deploy fails or production looks worse:

1. **Alert the user right away,** with the harness's notification tool if it
   has one.
2. **Start the fix in parallel.** Give a subagent the evidence: the error, the
   deploy, the merge commit, and when it started. It follows the
   `diagnosing-bugs` guide in `standards` and opens a fix PR. It doesn't
   merge.
3. **Decide what to do now.** If the user already said to revert or roll
   back in this case, do it. Otherwise ask with the harness's question tool,
   and don't revert or roll back until they answer. Give the options with
   your recommendation first: revert the merge, roll back the deploy, wait
   for the fix, or accept it. Say who is affected and how fast each option
   takes effect.

## 5. Finish the chores

Look through the thread, the PR description, the review ledger, and the linked
issues for what the user would otherwise still have to do:

- **Issues:** close the ones this PR fully resolves, with a comment linking
  it. Comment on a partly resolved one and leave it open.
- **Other PRs:** find open PRs for the same thing (by issue, files, and
  title). Comment with a link to what landed, and close the redundant ones.
- **Follow-ups:** file an issue for each deferred follow-up if the repo
  tracks work in issues. Otherwise list it in the report.
- **Promises:** anything said in the thread or PR that isn't done yet, like a
  doc, a changelog entry, a flag to turn on, or a reply someone is waiting
  for.
- **Cleanup:** delete the merged branch if the repo doesn't.

Write every comment with `pr-writing`.

## 6. Retro

Most landings don't need one. Run [retro](../retro/SKILL.md) only when the
session hit something a change to the environment would prevent next time: a
mistake a check could have caught, a missing or wrong instruction, a
correction from the user, CI or merge failures, a production problem, or a
step that was slow every time. A big diff or several review rounds isn't a
reason. Report at most three findings.

## Report

Use your usual report sections. The main one is **Landing**:

- **Summary** says which it is: landed and healthy, landed with a problem, or
  not landed.
- **Status** has the PR link, the merge commit, what deployed, and how far the
  production check got.
- **Landing** has the fixes it took to merge, what you checked in production
  with the numbers, and what you closed, commented on, and filed, with links.
- **Retro** appears only when you ran one. Which retro fixes to make goes
  under **Needs you**.
