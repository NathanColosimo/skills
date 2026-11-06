---
name: pr-comments
description: Write and post GitHub comments on the user's behalf. Use whenever leaving a PR comment, review comment, or reply on GitHub.
---

# PR comments

## Attribution

Start every comment you post on the user's behalf with this note:

```md
> [!NOTE]
> 🤖 **<model> responding on behalf of <user>**

The comment starts here.
```

Use the public model name the harness reports and the user's name or GitHub
login. If the model name isn't available, use the harness name. Do not guess.
Add no other heading, signature, or rule.

This applies to top-level comments, inline review comments, replies to bots
and reviewers, and the explanation you leave before resolving a thread. It
does not apply to PR descriptions, commit messages, or text the user asked you
to post exactly as written.

## Writing

- Lead with the conclusion in one sentence.
- Then the evidence: the code (`file:line` or a permalink), the check, the
  output, or the reproduction.
- Keep it short. No thanks, no filler, no status narration.
- Separate what you verified from what you judge.
- Show evidence that fits the claim, the same way `file-pr` does: real output,
  a before-and-after capture, a measured number. Never retype or tidy output.
- Say what you didn't check, in one sentence.
- Use a list or a short code block when it reads more easily than prose.

Common shapes:

- **Fixed:** "Fixed in `<sha>`: <what changed>." Add one line of why if it
  isn't obvious.
- **Declined:** "Not changing this: <reason>." Cite the code or the rule.
  Offer a follow-up only if one is real.
- **Question:** the question first, then what you checked and the options,
  with your recommendation.
- **Review finding:** what is wrong, where, why it matters, and the smallest
  fix.

## Posting

1. Check the whole comment, including quotes and attachments, for secrets and
   private details.
2. Preview the Markdown so quotes and blank lines render as intended.
3. After posting, confirm GitHub returned the comment or review URL.
4. Resolve a thread only after your reply posted.
