---
name: file-pr
description: File or update a pull request whose description shows the change works, not only says so. Use when the user asks to file, open, create, or update a PR or its description, or to prepare a change for review.
---

# File PR

A reviewer spends most of their time recreating what the author already saw:
the page, the command, the output. Put that in the description. A sentence
saying "fixed the layout on mobile" is a claim. The same page at the same phone
width, before and after, is evidence.

When the user asks you to file or update the PR, that is the go-ahead. If they
only asked for a draft, show it to them before posting.

## Before filing

1. Check whether a PR for this branch already exists. If one does, update it.
2. Rebase onto the latest base branch.
3. Run the `standards` simplify pass on the full diff against the base. Fix
   what it finds and re-run the checks.
4. Read the final diff. Confirm it matches the goal and contains nothing
   unrelated.
5. Gather the evidence (see "Evidence") while the before and after are easy to
   capture.

## Title

The title usually becomes the commit message. Follow the repo's conventions
(check recent merged PRs). Say what changes for the user or the codebase, not
the mechanism.

> ❌ perf(server): negotiate permessage-deflate on the websocket
>
> ✅ perf(server): cut websocket frame size by 70% with compression

## Description

Most readers stop early, so the order matters. Each part should work for a
reader who stops right after it.

```markdown
> Written by <model> on behalf of @<handle>. @<handle> has not reviewed it yet.

<The problem, in one paragraph: what was wrong or missing, for whom, and how
it showed up. Real numbers when there are any.>

## Changes
- <one bullet per idea, grouped by area. Say what and why. Not a file list.>

## Evidence
<captures, outputs, or measurements that fit the change. See "Evidence".>

## Notes
- <only what a reviewer needs: decisions, trade-offs, what you tried that
  didn't work, what's untested, follow-ups, what this is stacked on>

## In short
<2-3 plain sentences someone outside the project would follow.>
```

Leave out a section that would be empty. If `review-loop` ran, put its Review
table after Evidence. If the repo has a PR template, keep it and put the
first line above it.

### The first line

It tells the reviewer how much a person is behind the change, so they know how
closely to review it. Pick the line that matches what the user actually did:

| What the user did | First line |
| --- | --- |
| Gave the task and approved the approach | `> Written by <model> on behalf of @<handle>. @<handle> has not reviewed it yet.` |
| Wrote a spec you implemented (an issue, a doc, a plan) | `> Written by <model> on behalf of @<handle>, following their spec. @<handle> has not reviewed it yet.` |
| Worked out the design with you (the architecture, the API, the trade-offs) | `> Written by <model> on behalf of @<handle>, who shaped the solution. @<handle> has not reviewed it yet.` |

- Choosing between options you offered is approving an approach, not shaping
  the solution. When unsure, use the plainer line.
- Change the ending to `@<handle> has reviewed it.` only when the user says
  they have.
- Use the public model name the harness reports, plus any subagent models that
  wrote part of the change. If it isn't available, write "an AI agent". Don't
  guess.
- Get the handle with `gh api user -q .login` when the signed-in account is
  the user's own. Otherwise ask.
- This line replaces any "Generated with" footer.

### In short

Write it for someone outside the project: a changelog reader, another
maintainer, the user in six months. If you can't explain the change in two or
three plain sentences, the change probably isn't clear yet.

> When a request fails, the server sends back a small JSON note. It used to
> repeat the status code twice and the message three times. Now each appears
> once.

### Writing rules

- Lead with the problem. Never open with a list of changes.
- Short sentences. Explain any term a newcomer to the codebase wouldn't know.
- Group changes by idea. A file list belongs in the diff, not the description.
- Be specific: numbers, error messages, before and after.
- Separate what you verified from what you believe.

> ❌ Removed implicit workspace carry-over from every "new thread" entry point.
> Deleted buildContextualThreadOptions and the v1 sidebar's seed-context
> machinery.
>
> ✅ My "new worktree" default was ignored when starting a thread from an
> existing worktree. Now new threads always use your defaults.

## Evidence

Use the evidence that fits the change. A screenshot proves a layout and says
nothing about speed. A benchmark proves speed and says nothing about a layout.

| Change | Evidence |
| --- | --- |
| UI | Screenshots of the same element before and after, at the same viewport and crop. A phone width when layout is involved. A short video for motion, hover, or a multi-step flow. |
| Bug fix | The same input on both sides and what came out each time, copied exactly. The regression test, and whether it failed before the fix. |
| Command or build | The real output of the same command before and after, with the exit code. Never retype or tidy it. |
| Performance or cost | What you measured, how (machine, inputs, number of runs), the numbers on both sides, and how much they varied. Run it more than once. |
| AI or agent behavior | The same real prompts on both sides, how answers were graded, time and cost per answer, and where the grading is weak. |
| New API or feature | The code someone would write to use it. A pure addition has no "before". |
| Anything else | A small table or diagram comparing both versions. |

Make before and after easy to compare: same size, same crop, same starting
state, so the only visible difference is the change. Keep each command or
prompt next to its output.

### Keep it honest

- **"Before" is what's live:** production, the base branch, or the last deploy.
  Never revert, stash, or hand-edit code to fake a "before".
- **Look at every capture** before using it. Check that it shows the change and
  that every image link loads.
- **Use demo or sanitized data only.** No real users, emails, tokens, or private
  messages in a capture.
- **Say what didn't happen:** a check that failed or couldn't run, a number that
  got worse, a test that wasn't run against the old code, a path nobody tried
  in a browser. One sentence tells the reviewer exactly what to check.
- **Don't commit screenshots or videos** to the branch. Attach them to the PR.
  If you can't upload them, say so in the description.
- **Invent nothing.** No numbers, results, or test runs you didn't see.
- **Security fixes are the exception.** Don't post a reproduction, payload, or
  exploit steps in a public PR. Describe the impact in general terms, follow
  the project's security policy, and keep the details private until the fix
  ships.

## Filing

- Check the title, description, and attachments for secrets and private
  details.
- Before posting, check that the first line matches what the user did, that
  every claim has evidence or says why there's none, and that "In short" makes
  sense on its own.
- Open a real PR, not a draft, so review bots run.
- If `gh pr create` fails because the GraphQL rate limit is used up, use REST:
  `gh api repos/<owner>/<repo>/pulls -f title=... -f head=... -f base=... -F body=@<file>`.
- If the user also asked you to babysit it, continue with `babysit-pr`.
- Don't post a follow-up comment unless the user's request needs one. For
  comments, use `pr-comments`.
