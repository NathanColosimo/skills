---
name: takeover
description: Take over existing work. Use when the user asks to take over a PR, branch, or agent thread, or requests a takeover.
---

# Takeover

Finish the original goal, and keep the original contributors' credit. Don't
defend an implementation just because someone already built it.

1. **Read the source:** the PR, branch, or thread, with its review findings
   and the user's later corrections. Find the actual code and current head,
   and account for uncommitted work. A handoff note is context, not proof.
2. **Start the continuation.** For a replacement PR, import the original
   commits onto a new branch and add your fixes as separate commits. If the
   user asked for an in-place or stacked continuation, do that. Don't
   overwrite unrelated work or change the original PR without permission.
3. **Keep the credit.** Preserve Git authorship and co-author trailers. Name
   the original contributors in the PR description and link the original PR.
   If the work will be squashed, keep human author and co-author credit in the
   merge commit, using verified identities, not guessed emails.
4. **Bring it up to date** with `modernize`. Rework what the same goal needs,
   not unrelated features. Run the `standards` simplify guide on the inherited
   diff without dropping intended behavior. Check the source PR again before
   you finish: it may have moved.
5. **Verify it yourself.** Reproduce the original failure and try realistic
   workflows. Say what stays unverified.
6. **File it,** when the request includes a PR, with `pr-writing`, then stay
   with it using `babysit-pr`. Merge or close the original PR only with
   permission.

Report what you inherited, what you changed, how you verified it, how credit
was kept, and anything left to decide.
