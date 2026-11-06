---
name: land
description: Land a finished PR. Merge it (through the merge queue if the repo has one), watch it deploy, check production, finish the follow-up chores, and run a short retro. Use when the user says "land", "land it", or "land the PR", usually after full-stop or full-send. Not for landing pages; that's the design skill.
---

# Land

The user wants to come back and find that the change merged, deployed, and
works in production, and that everything left to do is done. They are not
watching. Your updates go unread until you stop, so keep going until the
work is finished or you hit something you can't fix with confidence.

A "land" request gives you permission to:

- merge the PR, or add it to the merge queue;
- rebase the PR's branch, fix conflicts and CI failures, and push with
  `--force-with-lease`;
- comment on, and close, other PRs and issues that this PR resolves.

It does not give you permission to revert, roll back, change production
config, or delete data. Ask first.

## 1. Merge

1. Find the PR (the one in this thread, or the one the user names). Check the
   merge gate from `full-send` on the latest head. If proof or review never
   happened, stop and say so. Landing is not a shortcut around them.
2. Merge with the repo's method. If the repo has a merge queue, add the PR to
   the queue (`gh pr merge <n>` with the repo's method queues it), unless it's
   already queued. Never use `--admin` or bypass branch protection. If the PR is
   in a stack, merge it with `stacked-prs`.
3. Wait until GitHub reports the PR as merged, using the watcher from
   `babysit-pr`. Don't poll.
4. If it doesn't merge, find out why and fix the obvious problems, then try
   again:
   - a conflict with the new base: rebase and resolve it;
   - a CI failure caused by this PR: fix it;
   - a flaky test or infrastructure failure: re-run it once;
   - kicked from the queue because another PR in the group failed: queue it
     again.

   Get proof for any fix that changes behavior. Stop after three failed
   attempts, or as soon as the problem needs a decision you can't make with
   confidence, such as a conflict where both sides changed behavior.

## 2. Deploy

Find out how the project ships: the workflows that run on the default
branch, the deployments on GitHub (`gh api repos/<o>/<r>/deployments`), the
hosting provider (Vercel, EAS, and so on), and the repo's deploy docs. If
nothing deploys on merge, say so and skip to step 4.

Wait for every deploy this merge starts, with a background command or a
monitor, not a polling loop. Then confirm the new version is live: the
deployed commit matches, and a quick check of the changed path works (the
page loads, the endpoint answers, the health check passes).

## 3. Check production

Do this when the change could misbehave in a way only production shows: a
performance change, an API change, a migration, auth, payments, background
jobs, or anything with real traffic behind it. Skip it for docs, tests, and
internal refactors with no runtime effect, and say you skipped it.

Use whatever read-only access you have: logs, traces, metrics, error
tracking (Axiom, Datadog, Sentry, the host's dashboards). Compare a window
after the deploy with the same window before it:

- error rate and new error types on the changed paths;
- latency on the changed endpoints, and the actual numbers for a performance
  change;
- the traffic you expected actually reaching the new code.

Watch long enough for real traffic to hit the change, usually 15 to 30
minutes. If you have no access, list exactly what the user should check.

## 4. When something goes wrong

If the deploy fails or production looks worse:

1. **Alert the user right away.** Use the harness's notification tool if it
   has one (`PushNotification` in Claude Code), and its question tool.
2. **Start the fix in parallel.** Hand the diagnosis to a subagent (in T3
   Code, `delegate_task`) with the evidence you have: the error, the deploy,
   the merge commit, and the time it started. It follows the
   `diagnosing-bugs` guide in `standards` and opens a fix PR. It does not
   merge.
3. **Advise on what to do now.** In the question to the user, give the
   options with your recommendation first: revert the merge, roll back the
   deploy, wait for the fix, or accept it as is. Include how bad it is (who is
   affected, how many) and how fast each option takes effect.

Don't revert or roll back without the user's answer, unless the user has
said to.

## 5. Finish the chores

Look for what the user would otherwise still have to do. Check the thread,
the PR description, the review ledger, and the linked issues.

- **Issues:** close issues that this PR fully resolves and that GitHub didn't
  close on its own, with a comment linking the PR. If it only partly resolves
  one, comment and leave it open.
- **Other PRs:** find open PRs that address the same thing (search by the
  issue, the files, and the title). Comment on each with a link to what
  landed. Close the ones that are now redundant. Leave open any that still
  add something, and say what in the comment.
- **Follow-ups:** for each follow-up the PR or review deferred, file an issue
  if the repo tracks work in issues, or list it in the report.
- **Promises:** anything said in the thread or PR that isn't done yet: a
  doc to update, a changelog entry, a flag to turn on, a reply someone is
  waiting for.
- **Cleanup:** delete the merged branch if the repo doesn't do it
  automatically.

Write every comment with `pr-writing`. Don't open new work beyond these
chores.

## 6. Retro

Only for a big change: a large diff, several review rounds, CI or merge
failures, a production problem, or a session where the user had to correct
you. Skip it otherwise, and say so.

Report **at most three** findings, ranked by how much fixing them would
help future work. Leave out everything else. Good findings are things that
cost real time or caused a real bug, and that one change would prevent:

- a check that would have caught a mistake (a lint rule, a type, a test);
- a missing or wrong instruction in the repo's instruction files or skills,
  or in the user's skills;
- information you needed and couldn't get, like logs or access to a service;
- a step that was slow every time.

For each one: what happened, its cost, and the single change that would
prevent it. Don't apply the changes. The user picks which to do.

## Report

When you stop, use these sections, and leave out any that would be empty:

- **Summary:** landed and healthy, landed with a problem, or not landed, and
  what that means for the user.
- **Status:** the PR link, the merge commit, what deployed, and how far the
  production check got.
- **Landing:** the fixes it took to merge, what you checked in production
  and the numbers you saw, and what you closed, commented on, and filed, with
  links.
- **Retro:** up to three findings, or "skipped: small change".
- **Needs you:** anything still waiting on the user, including which retro
  fixes to make, with your recommendation first.

In T3 Code, call `unwatch_pull_request` before you stop or ask a question.
