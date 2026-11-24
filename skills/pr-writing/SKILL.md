---
name: pr-writing
description: Write and post anything on a pull request for the user, including the branch name, the title, the description, comments, review comments, and replies. Use when the user asks to file, open, create, or update a PR or its description, to prepare a change for review, or whenever you post a GitHub comment for them.
---

# PR writing

This covers everything you write on a PR: the branch name, the title, the
description, and comments. Read "Public repos" before writing anything in a
public repo.

A reader should know from the title alone what the PR is for, and from the
top of the description what it changes and how risky it is. Write for someone
who reads only that far.

When the user asks you to file or update the PR, that is the go-ahead. If they
only asked for a draft, show it to them before posting.

## Public repos

Everything you post in a public repo is visible to anyone, forever. Some
public repos are one part of a product that also has private code. Write only
what someone reading the public code could already know.

Check with `gh repo view --json visibility -q .visibility`. If it says
`PUBLIC` and the work involved anything private (another repo, internal docs,
a private ticket, a conversation), check the branch name, title, description,
comments, and commit messages for:

- names of private repos, services, files, functions, or config;
- internal URLs, hostnames, dashboards, log or trace links, and ticket or
  chat links;
- how the private side works inside: its architecture, data model, limits,
  or why it behaves the way it does;
- customers, incidents, internal metrics, costs, and unannounced plans;
- captures, logs, or output that show any of the above.

Describe the private side only by its public contract: the documented API,
the protocol, or behavior a user can see. "The server can now return `409`
when two writes race" is fine. Which internal service returns it, and why, is
not. If you can't explain the change without private details, ask the user
before posting. It can't be taken back.

**Security fixes:** read the project's security policy before you name the
branch or write anything. It overrides this skill, including the required
Type and Risk lines and whether a public branch or PR may exist yet. If it
says to wait until the fix ships, use neutral wording everywhere. When
it allows, say plainly that it's a security fix and what an attacker could
have done, in general terms. Never post a reproduction, payload, or exploit
steps in a public repo.

## Before filing

1. Check whether a PR for this branch already exists. If one does, update it.
2. Rebase onto the latest base branch.
3. Run the `standards` simplify pass on the full diff and re-run the checks.
4. Read the final diff. Confirm it matches the goal and has nothing
   unrelated. Split out unrelated work. When related changes belong together,
   such as a fix and the refactor it needs, say both in the title and the
   Type line.
5. Gather the evidence while the before and after are easy to capture.

## Branch name

When you create the branch, name it after what the change does, not where
it happens. Follow the repo's naming convention. With none, use the usual
prefix, then 2-5 words in kebab case.

> ❌ `nathanc/plugins-link-fetch`
>
> ✅ `nathanc/block-private-link-fetches`

Don't rename a branch that already has an open PR. GitHub closes the PR.

## Title

The title usually becomes the commit message. Follow the repo's format (check
recent merged PRs). Within it, say the purpose: what changes for the user or
the codebase. Not the mechanism. Lead with the kind of change when the repo
has no prefix of its own. Say when it's a security fix (see "Public repos"
for when to wait).

> ❌ Check every address and redirect a link fetch connects to
>
> ✅ Security: stop pasted links from reaching private network addresses

> ❌ perf(server): negotiate permessage-deflate on the websocket
>
> ✅ perf(server): cut websocket frame size by 70% with compression

## Description

```markdown
> Written by <model> on behalf of @<handle>. @<handle> has not reviewed it yet.

## In short
<2-3 plain sentences someone outside the project would follow: what this
does, and why it matters.>

- **Type:** <Bug fix | Security fix | Feature | Performance | Refactor | Docs | Chore>
- **Risk:** <Low | Medium | High>. <What could break, and who would notice.>
- **Depends on:** <#123, or what must happen first. Leave out if nothing.>

## Why
<The problem: what was wrong or missing, for whom, and how it showed up. Real
numbers when there are any.>

## Changes
- <one bullet per idea, grouped by area. Say what and why. Not a file list.>

## Evidence
<captures, outputs, or measurements that fit the change. See "Evidence".>

## Notes
- <only what a reviewer needs: decisions, trade-offs, what's untested,
  follow-ups>
```

Leave out a section that would be empty. If `review-loop` ran, put its Review
table after Evidence. If the repo has a PR template, keep it and put the first
line, In short, and the Type, Risk, and Depends on lines above it. Use the
template's sections for the rest.

### The first line

It tells the reviewer how much a person is behind the change. Pick the line
that matches what the user actually did:

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
  wrote part of the change. If it isn't available, write "an AI agent".
- Get the handle with `gh api user -q .login` when the signed-in account is
  the user's own. Otherwise ask.
- This line replaces any "Generated with" footer.

### In short, Type, and Risk

**In short:** if you can't say it in two or three plain sentences, the change
isn't clear yet.

> When you paste a link, Kompose fetches the page to read its title. A link
> could point that fetch at machines on a private network instead. Now every
> address and redirect is checked, so it only reaches the public internet.

**Type** is the main purpose. When a PR does two things, name both
("Security fix + refactor").

**Risk** is what could go wrong if this change has a bug, not whether you
think it has one:

- **Low:** small or isolated, easy to revert. Docs, tests, a copy change.
- **Medium:** changes a shared path, a dependency, or behavior users see.
- **High:** touches auth, payments, data, migrations, or security checks, or
  is hard to revert.

> **Risk:** High. It changes a security check. A bug could stop link previews
> from loading, or let a link reach a private address again.

### Writing rules

- Short sentences. Explain any term a newcomer wouldn't know.
- Group changes by idea. A file list belongs in the diff.
- Be specific: numbers, error messages, before and after.
- Separate what you verified from what you believe.
- Keep stack and history notes ("bottom of the stack now that #58 merged") in
  Depends on or Notes, never in Why.

> ❌ Removed implicit workspace carry-over from every "new thread" entry point.
> Deleted buildContextualThreadOptions and the v1 sidebar's seed-context
> machinery.
>
> ✅ My "new worktree" default was ignored when starting a thread from an
> existing worktree. Now new threads always use your defaults.

## Evidence

Use the evidence that fits the change:

| Change | Evidence |
| --- | --- |
| UI | Screenshots of the same element before and after, at the same viewport and crop. A phone width when layout is involved. A short video for motion, hover, or a multi-step flow. |
| Bug fix | The same input on both sides and what came out each time, copied exactly. The regression test, and whether it failed before the fix. |
| Command or build | The real output of the same command before and after, with the exit code. |
| Performance or cost | What you measured, how (machine, inputs, runs), both numbers, and how much they varied. Run it more than once. |
| AI or agent behavior | The same real prompts on both sides, how answers were graded, time and cost per answer, and where the grading is weak. |
| New API or feature | The code someone would write to use it. |
| Anything else | A small table or diagram comparing both versions. |

Keep each command or prompt next to its output, and make before and after
differ only in the change.

### Keep it honest

- **"Before" is what's live:** production, the base branch, or the last
  deploy. Never revert or hand-edit code to fake a "before".
- **Look at every capture** before using it, and check every image link loads.
- **Use demo or sanitized data only.** No real users, emails, tokens, or
  private messages.
- **Say what didn't happen:** a check that failed or didn't run, a number that
  got worse, a path nobody tried.
- **Never retype or tidy output, and invent nothing.**
- **Don't commit screenshots or videos.** Attach them to the PR, or say you
  couldn't.

## Filing

- Check the title, description, and attachments for secrets and private
  details, and in a public repo for anything "Public repos" lists.
- Before posting, check that the title says the purpose, In short makes sense
  on its own, Type and Risk are filled in, the first line matches what the
  user did, and every claim has evidence or says why there's none.
- Open a real PR, not a draft, so review bots run.
- To file a stack of PRs, create it with `stacked-prs`.
- If `gh pr create` fails because the GraphQL rate limit is used up, use REST:
  `gh api repos/<owner>/<repo>/pulls -f title=... -f head=... -f base=... -F body=@<file>`.
- If the user also asked you to babysit it, continue with `babysit-pr`.
- Don't post a follow-up comment unless the user's request needs one.

## Comments

### Attribution

Start every comment you post on the user's behalf with this note:

```md
> [!NOTE]
> 🤖 **<model> responding on behalf of <user>**

The comment starts here.
```

Use the public model name the harness reports and the user's name or GitHub
login. If the model name isn't available, use the harness name. Add no other
heading, signature, or rule.

This applies to top-level comments, inline review comments, replies to bots
and reviewers, and the note you leave before resolving a thread. It does not
apply to PR descriptions, commit messages, or text the user asked you to post
exactly as written.

### Writing a comment

- Lead with the conclusion in one sentence.
- Then the evidence: the code (`file:line` or a permalink), the check, the
  output, or the reproduction, chosen the way "Evidence" says.
- Keep it short. No thanks, no filler, no status narration.
- Separate what you verified from what you judge, and say what you didn't
  check.

Common shapes:

- **Fixed:** "Fixed in `<sha>`: <what changed>." Add one line of why if it
  isn't obvious.
- **Declined:** "Not changing this: <reason>." Cite the code or the rule.
- **Question:** the question first, then what you checked and the options,
  with your recommendation.
- **Review finding:** what is wrong, where, why it matters, and the smallest
  fix.

### Posting a comment

1. Check the whole comment, including quotes and attachments, for secrets and
   private details, and in a public repo for anything "Public repos" lists.
2. Preview the Markdown so quotes and blank lines render as intended.
3. After posting, confirm GitHub returned the comment or review URL.
4. Resolve a thread only after your reply posted.
