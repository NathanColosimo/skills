---
name: review-loop
description: Review a change with other models in a loop until a stop condition is met. Use when the user says "review loop", "sol loop", "council", or asks to review with specific models until something is true.
---

# Review loop

Get review from other models, answer each finding, and repeat until the stop
condition is met. You own the change. Reviewers advise. Push back when they are
wrong or overreaching.

## 1. Reviewers and stop condition

**Reviewers:**

- Default, and "sol loop": **GPT Sol 6.1**.
- "council": **Claude Opus 5.5** and **GPT Sol 6.1**, in parallel.
- If the user names models, use those instead.

Run every reviewer at high reasoning effort. Resolve the model IDs at runtime;
do not hardcode them. If a reviewer is unavailable, report that and stop. Do not
substitute another model.

**Stop condition:** use the user's, for example "until both approve", "3
rounds", "until every score is 9 or higher", or "until no blockers". The
default is that every reviewer approves with no open blocker or should.

**Budget:** 3 rounds by default. Go up to 5 only for security, auth,
permissions, data loss, or concurrency while a blocker or should is still open
with evidence, or when the user asks. Stop early when a round returns only
nits. Running out of budget is not approval.

## 2. Before round 1

1. Run `git status --short`. Do not stash, discard, or include unrelated
   changes. If the change's paths don't separate cleanly from other work, stop
   and ask.
2. Find the base after `git fetch origin`:
   - PR: `gh pr view <n> --json baseRefName,headRefOid`, then
     `git merge-base HEAD origin/<baseRefName>`.
   - Local: `git merge-base HEAD origin/<default-branch>`.
3. Fix what you already know about: outstanding PR comments, failing checks,
   known bugs. Do not send reviewers code you know is broken.
4. Run the `standards` simplify pass on the diff yourself, then run the checks
   that cover it.
5. Write the intent and what is out of scope in 1-2 sentences.

## 3. Start reviewers

In T3 Code, call `orchestrator_capabilities` once, then one `delegate_task` per
reviewer (`role: "review"`, `mode: "async"`), with a new `clientRequestId`
each round. Outside T3, use the harness's subagent tool on the right model. In
Claude Code, a Claude reviewer can be a native `Agent` with the model set.

Do not edit the files under review while reviewers run. Wait for the
completion notice; do not poll. A timeout, error, or empty reply is not
approval.

Round 1 brief (delegates get no history):

```
Review only. Do not edit, commit, push, comment on PRs, or start subagents.
Repo: <abs path>  Base: <sha>
Intent: <intent>  Out of scope: <scope>  Checks: <results>
Diff: git diff <base> [-- <paths>]; also read untracked files from git status --short.
Standards: read <abs path to the installed standards/SKILL.md> and review against it.
Read the surrounding code. Find bugs, broken callers, and mismatches with the intent.
Hold the change to its intent. Other paths, rare cases, small perf costs, and
extra compatibility are nits.
Reply:
VERDICT: APPROVE or CHANGES
SCORE: <n>/10
S1 [blocker|should|nit] <file>:<line> <claim>. Fix: <suggestion>
```

Find the standards path with `ls ~/.agents/skills/standards/SKILL.md
~/.claude/skills/standards/SKILL.md`. If neither exists, paste the rules into
the brief.

## 4. Answer findings

Check every finding against the code yourself, and set its severity yourself.
A reviewer's label is a suggestion.

- **Agree:** make the smallest fix. Prefer deleting or narrowing code over a
  new helper, option, guard, or test.
- **Disagree:** say why, with evidence (file:line, a test, output).
- **Decline:** out of scope or a nit. One line, listed as a follow-up.

Push back when a reviewer is overreaching. Decline, with a reason:

- requests that break `standards`, such as adding a compatibility shim, a
  wrapper, a defensive branch for a case that can't happen, or a test that
  restates the code;
- hypothetical paths the intent doesn't cover;
- style preferences the repo doesn't share;
- anything that grows the diff without fixing a real bug in the intended case.

Never agree just to end the loop. After fixing, re-run the checks and
`git diff --shortstat <base>`. If review grew the diff, cut first.

Keep a ledger: id, reviewer, severity, outcome (fixed / disagree / declined),
and the evidence for each.

## 5. Next round

Start a round only if budget remains and the stop condition isn't met. Send
the round 1 brief, the ledger, and the change since the last round. Ask each
reviewer to check open ids and changed code only, and mark each old id
`resolved` or `still open: <reason>`.

If a reviewer still disputes an item after two replies, stop arguing. Show
both sides in 2-3 lines each and let the user decide.

## 6. Finish

Do not push during the loop. Push afterwards only if the user asked you to
push, ship, or update the PR.

If the work has a PR, put this section in its description, right after
Evidence. Edit the description; do not post a comment.

```markdown
## Review

| Reviewer | Round 1 | Round 2 |
| --- | --- | --- |
| GPT Sol 6.1 | 7/10 | 9/10, approved |
```

Write `no score` when a reviewer gave none. Never invent one.

Report: the reviewers, the rounds, what changed because of review, the diff
size before and after, and each declined or disputed finding with its reason.
