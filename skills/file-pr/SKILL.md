---
name: file-pr
description: File or update a clear, readable pull request. Use when the user asks to file, open, create, or update a PR or its description.
---

# File PR

A reviewer should understand the PR in 30 seconds: what was wrong, what is
different now, and why they can trust it.

## Before filing

1. Check whether a PR for this branch already exists. If one does, update it.
2. Rebase onto the latest base branch.
3. Run the `standards` simplify pass on the full diff against the base. Fix
   what it finds and re-run the checks.
4. Read the final diff. Confirm it matches the goal and contains nothing
   unrelated.

## Title

The title usually becomes the commit message. Follow the repo's conventions
(check recent merged PRs). Say what changes for the user or the codebase, not
the mechanism.

> ❌ perf(server): negotiate permessage-deflate on the websocket
>
> ✅ perf(server): cut websocket frame size by 70% with compression

## Description

Use this shape. Leave out a section that would be empty.

```markdown
<1-3 sentences: the problem, in plain words. What someone saw or what was
wrong, and why it matters.>

<1-3 sentences: what is different now, described as behavior.>

## Changes
- <one bullet per idea, not per file. Say what and why.>

## Proof
- <what you ran or saw: commands and results, a reproduction, screenshots>

## Notes
- <only what a reviewer needs: risks, decisions you made, follow-ups,
  what this PR is stacked on>

Created with <model> in <harness>.
```

Writing rules:

- Lead with the problem. Never open with a list of changes.
- Short sentences. Explain any term a newcomer to the codebase wouldn't know.
- Group changes by idea. A file list belongs in the diff, not the description.
- Be specific: numbers, error messages, before and after.
- Separate what you verified from what you believe.
- If `review-loop` ran, include its Review table above the model line.

> ❌ Removed implicit workspace carry-over from every "new thread" entry point.
> Deleted buildContextualThreadOptions and the v1 sidebar's seed-context
> machinery.
>
> ✅ My "new worktree" default was ignored when starting a thread from an
> existing worktree. Now new threads always use your defaults.

For the last line, use the public model name the harness reports, plus any
subagent models that wrote part of the change. If the model name isn't
available, name only the harness. Do not guess.

## Filing

- Check the title, description, and attachments for secrets and private
  details.
- Open a real PR, not a draft, so review bots run.
- If `gh pr create` fails because the GraphQL rate limit is used up, use REST:
  `gh api repos/<owner>/<repo>/pulls -f title=... -f head=... -f base=... -F body=@<file>`.
- If the user also asked you to babysit it, continue with `babysit-pr`.
- Don't post a follow-up comment unless the user's request needs one. For
  comments, use `pr-comments`.
