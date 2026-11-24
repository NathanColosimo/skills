---
name: review-loop
description: Review a change with other models in a loop until a stop condition is met. Use when the user says "review loop", "sol loop", "council", or asks to review with specific models until something is true.
---

# Review loop

Get review from other models, answer each finding, and repeat until the stop
condition is met. You own the change. Reviewers advise, so push back when they
are wrong or overreaching.

## 1. Reviewers and stop condition

**Reviewers:**

- Default, and "sol loop": **GPT Sol 6.2** at high reasoning.
- "council": **Claude Opus 5.5** at high reasoning and **GPT Sol 6.2** at high
  reasoning, in parallel.
- If the user names models, use those instead, at high reasoning.

Resolve the model IDs at runtime. If a reviewer is unavailable, report that
and stop. Don't substitute another model.

**Stop condition:** the user's, such as "until both approve", "3 rounds", or
"until every score is 9 or higher". By default, stop when every reviewer
approves with no open blocker or should that names a scenario a user can hit.
Don't chase a score unless the user asked for one: each extra round finds
rarer cases, and the diff grows to handle them.

**Budget:** 3 rounds. Go up to 5 only when the user asks, or for security,
auth, permissions, data loss, or concurrency while a blocker or should is
still open with evidence. Stop early when a round returns only nits. Running
out of budget is not approval.

## 2. Before round 1

1. Run `git status --short`. Don't stash, discard, or include unrelated
   changes. If the change doesn't separate cleanly from other work, stop and
   ask.
2. Find the base after `git fetch origin`. For a PR:
   `gh pr view <n> --json baseRefName`, then
   `git merge-base HEAD origin/<baseRefName>`. Otherwise use the default
   branch.
3. Fix what you already know about: open PR comments, failing checks, known
   bugs. Then run the `standards` simplify guide on the diff and the checks
   that cover it.
4. Write the intent (the problems the change fixes) and what is out of scope,
   in 1-2 sentences.
5. Record the size: `git diff --shortstat <base>`.

## 3. Start reviewers

In T3 Code, call `orchestrator_capabilities` once, then one `delegate_task`
per reviewer (`role: "review"`, `mode: "async"`), with a new `clientRequestId`
each round. Elsewhere, use the harness's subagent tool on the right model.

Don't edit the files under review while reviewers run. Wait for the completion
notice; don't poll. A timeout, error, or empty reply is not approval.

Round 1 brief (delegates get no history):

```
Review only. Do not edit, commit, push, comment on PRs, or start subagents.
Repo: <abs path>  Base: <sha>
Intent: <intent>  Out of scope: <scope>  Checks: <results>
Diff: git diff <base> [-- <paths>]; also read untracked files from git status --short.
Standards: read <abs path to the installed standards/SKILL.md> and review against it.
Read the surrounding code. Find bugs, broken callers, and mismatches with the intent.
Hold the change to its intent. Flag what leaves the change wrong or incomplete.
Separate improvements (other paths, rare cases, small perf costs, extra
compatibility) are nits.
Every blocker or should about behavior needs a scenario: the steps a real user
or caller takes, what they see, and how likely it is. Without one, it's a nit.
Also list code the change could delete and still fix its intent: unused
machinery, guards for cases that can't happen, tests that repeat each other.
Each deletion is a should.
Reply:
VERDICT: APPROVE or CHANGES
SCORE: <n>/10
S1 [blocker|should|nit] <file>:<line> <claim>. Scenario: <steps → what goes wrong>. Fix: <suggestion>
D1 [should] <file>:<lines> <what to delete and why the intent still holds>
```

Find the standards path with `ls ~/.agents/skills/standards/SKILL.md
~/.claude/skills/standards/SKILL.md`. If neither exists, paste the rules into
the brief.

## 4. Answer findings

Check every finding against the code yourself, and set its severity yourself.
A reviewer's label is a suggestion.

- **Agree:** make the smallest fix. Narrow a condition before adding a guard,
  and add a guard before adding a mechanism.
- **Disagree:** say why, with evidence (`file:line`, a test, output).
- **Decline:** out of scope or a nit. One line, listed as a follow-up.

Decline overreach, with a reason:

- anything that breaks `standards`, such as a shim, a wrapper, a guard for a
  case that can't happen, or a test that restates the code;
- hypothetical paths the intent doesn't cover;
- style preferences the repo doesn't share;
- anything that grows the diff when the change is correct and complete
  without it. That's a follow-up PR.

Never agree just to end the loop. After fixing, re-run the checks and
`git diff --shortstat <base>`. If review grew the diff, revert every addition
that no scenario justifies.

Keep a ledger: id, reviewer, severity, outcome (fixed, disagreed, declined),
and the evidence.

## 5. Next round

Start another round only if budget remains and the stop condition isn't met.
Send the round 1 brief, the ledger, and the change since the last round. Ask
each reviewer to check only open ids and changed code, and to mark each old id
`resolved` or `still open: <reason>`.

If a reviewer still disputes an item after two replies, stop arguing. Give
both sides in 2-3 lines each and let the user decide.

## 6. Finish

Run the simplify guide on the whole diff again, because review fixes pile up
and nothing else removes them. If that changed behavior, re-run the checks and
send one short confirmation round on the changed code.

Don't push during the loop. Push afterwards only if the user asked you to
push, ship, or update the PR.

This section goes in the PR description, after Evidence. Edit it in now if
the PR exists, or add it when the PR is filed:

```markdown
## Review

| Reviewer | Round 1 | Round 2 |
| --- | --- | --- |
| GPT Sol 6.2 | 7/10 | 9/10, approved |
```

Write `no score` when a reviewer gave none.

Report the reviewers, the rounds, what changed because of review, the diff
size before review, after review, and after the final simplify pass, and each
declined or disputed finding with its reason.
