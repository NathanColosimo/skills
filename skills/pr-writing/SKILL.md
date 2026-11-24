---
name: pr-writing
description: Write and post anything on a pull request for the user, including the branch name, the title, the description, comments, review comments, and replies. Use when the user asks to file, open, create, or update a PR or its description, to prepare a change for review, or whenever you post a GitHub comment for them.
---

# PR writing

This covers the words on a PR: the branch name, the title, the description,
and comments. Getting the change itself ready is not this skill's job.

A reader should know from the title what the PR is for, and from the top of
the description what it changes and how risky it is.

If the user asked you to file or update the PR, post it. If they asked for a
draft, show it to them first.

## Public repos

Check everything you post for secrets and private details. Everything posted in a public repo is visible to anyone, forever. Check with
`gh repo view --json visibility -q .visibility`. In a public repo, write only
what someone reading the public code could already know. Keep these out of
branch names, titles, descriptions, comments, and commit messages:

- private names (repos, services, files, functions, config) and internal
  links (URLs, hostnames, dashboards, traces, tickets, chats);
- how a private system works inside, and why;
- customers, incidents, internal metrics, costs, and unannounced plans;
- captures or logs that show any of these.

Describe a private system by its public contract: "the server can now return
`409` when two writes race", not which internal service returns it. If you
can't explain the change without private details, ask the user first.

**Security fixes:** the project's security policy comes first. It decides
whether a public branch or PR may exist yet, and what it may say. When it
allows, say plainly that this is a security fix and what an attacker could
have done, in general terms. Never post a reproduction, payload, or exploit
steps in public.

## Branch and title

Both say what the change is for, not where it is or how it works. Follow the
repo's format (check recent merged PRs), and name the kind of change when the
format doesn't.

| | ❌ | ✅ |
| --- | --- | --- |
| Branch | `plugins-link-fetch` | `block-private-link-fetches` |
| Title | Check every address and redirect a link fetch connects to | Security: stop pasted links from reaching private network addresses |
| Title | perf(server): negotiate permessage-deflate on the websocket | perf(server): cut websocket frame size by 70% with compression |

## Description

```markdown
> Written by <model> on behalf of @<handle><role>. @<handle> has not reviewed it yet.

## In short
<2-3 plain sentences an outsider would follow: what this does and why it
matters.>

- **Type:** <bug fix | security fix | feature | performance | refactor | docs | chore>
- **Risk:** <Low | Medium | High>. <What breaks if this is wrong, and who notices.>
- **Depends on:** <#123, or what must happen first>

## Why
<What was wrong or missing, for whom, and how it showed up. Real numbers when
there are any.>

## Changes
- <One bullet per idea: what and why. Not a file list.>

## Evidence
<Captures, output, or measurements. See "Evidence".>

## Notes
- <Only what a reviewer needs: trade-offs, what's untested, follow-ups.>
```

- Leave out any section or line that would be empty.
- **Type** names both when the PR does two related things ("security fix +
  refactor").
- **Risk** rates what a bug in this change could break, not how sure you are.
  Auth, payments, data, migrations, and security checks are High. Docs, tests,
  and isolated changes are Low.
- If the repo has a PR template, put everything down to **Depends on** above
  it, and fill in the template for the rest.

### The first line

It tells the reviewer how much of a person is behind the change.

- `<role>` matches what the user did. Gave the task and approved the approach:
  nothing. Wrote a spec you implemented: `, following their spec`. Worked out
  the design with you: `, who shaped the solution`. Picking between options
  you offered is approving, not shaping.
- Write `has reviewed it` only when the user says so.
- `<model>` is the public model name the harness reports, plus any subagent
  models that wrote part of the change. If unknown, write "an AI agent".
- `<handle>` comes from `gh api user -q .login` when the signed-in account is
  the user's own. Otherwise ask.
- This line replaces any "Generated with" footer.

### Wording

- Short sentences. Explain any term a newcomer wouldn't know.
- Say what a user saw, with numbers and error messages, not which functions
  changed.
- Separate what you verified from what you believe.
- Stack and history notes go in Depends on or Notes, not in Why.

> ❌ Deleted buildContextualThreadOptions and the sidebar's seed-context
> machinery.
>
> ✅ My "new worktree" default was ignored when starting a thread from an
> existing worktree. Now new threads always use your defaults.

## Evidence

Show what you saw, in the form that fits the change:

| Change | Evidence |
| --- | --- |
| UI | The same element before and after, at the same viewport and crop. A phone width when layout is involved. A short video for motion or a multi-step flow. |
| Bug fix, command, or build | The same input or command on both sides, with the exact output and exit code of each. The regression test, and whether it failed before the fix. |
| Performance or cost | What you measured and how (machine, inputs, runs), both numbers, and how much they varied. |
| AI or agent behavior | The same real prompts on both sides, how answers were graded, time and cost per answer, and where the grading is weak. |
| New API or feature | The code someone would write to use it. |
| Anything else | A small table or diagram comparing both versions. |

- **"Before" is what's live:** production, the base branch, or the last
  deploy. Never revert or edit code to fake one.
- **Copy output exactly.** Never retype or tidy it, and invent nothing.
- **Say what didn't happen:** a check that failed or didn't run, a number that
  got worse, a path nobody tried.
- **Demo or sanitized data only.** No real users, emails, tokens, or private
  messages.
- **Look at every capture** and check its link loads. Attach media to the PR;
  never commit it. If you can't upload it, say so.

## Filing

- If the branch already has a PR, update it.
- Read the final diff first. The description must match it.
- Open a ready PR, not a draft, so review bots run. File a stack with
  `stacked-prs`.
- If `gh pr create` fails because the GraphQL rate limit is used up, use REST:
  `gh api repos/<owner>/<repo>/pulls -f title=... -f head=... -f base=... -F body=@<file>`.
- Don't add a follow-up comment unless the request needs one.

## Comments

Start every comment you post for the user with this note, and add no other
heading or signature. The only exception is text the user asked you to post
exactly as written.

```md
> [!NOTE]
> 🤖 **<model> responding on behalf of <user>**

The comment starts here.
```

- Lead with the conclusion in one sentence.
- Then the evidence: the code (`file:line` or a permalink), the check, the
  output, or the reproduction.
- Keep it short. No thanks, no filler, no status updates.
- Separate what you verified from what you judge, and say what you didn't
  check.
- A fix: "Fixed in `<sha>`: <what changed>." A decline: "Not changing this:
  <reason>", citing the code or the rule.
- A question: the question first, then what you checked and the options, with
  your recommendation. A finding: what is wrong, where, why it matters, and
  the smallest fix.

After posting, confirm GitHub returned the comment's URL, and only then
resolve the thread.
