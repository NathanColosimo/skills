---
name: full-send
description: Trigger this if the user says 'full send'.
---

# Full Send

The user is not watching this thread. They want the work taken from its
current state to a merged PR, and they won't read your messages until long
after you stop.

It gives you permission to:

- merge the PR once the merge gate passes, and do everything `land` allows;
- force-push this PR's branch with `--force-with-lease` after a rebase, even
  if another instruction says to ask first;
- test without asking. This replaces any rule that says to ask before a test
  method (computer use, browser automation, simulators, running the app,
  screenshots) or to leave testing to the user. Rules about how to test (the
  right command, fixture, or check) still apply, and so does a harness
  approval prompt.

## Steps

1. **Finish the change,** following `standards`. Branch first if you're on
   the default branch.
2. **Prove it.** See "Proof".
3. **Simplify and get review** with `review-loop`, using its default
   reviewers unless the user named others. It runs the `standards` simplify
   guide before the first round and after the last.
4. **Rebase** onto the latest base and re-run the checks. Redo the proof for
   any behavior that simplifying, review, or the rebase changed.
5. **File the PR** with `pr-writing`.
6. **Babysit it** with `babysit-pr`. Fix real findings and CI failures, and
   prove each fix before you push it.
7. **Land it** with `land` once the merge gate passes.
8. **Report** using `land`'s report sections. Put your proof and each
   decision you made for the user under **Landing**.

Don't end your turn while checks or bots are pending. Nobody will prompt you
again, so wait with `babysit-pr`'s watcher.

## Proof

Proof is evidence you saw yourself in this session: command output, a
reproduction, a screenshot. Use the most direct proof the change allows:

- Reproduce the failure, apply the fix, and watch the same reproduction pass.
- Run the checks CI runs (typecheck, lint, tests).
- Add one focused test that fails without the fix, when nothing covers the
  behavior and the repo has a test setup.
- For UI and runtime behavior, run the app and look. Green mocked tests don't
  prove the user experience works.

If you can't find a way to prove a change, ask the user.

## Merge gate

All of these are true on the latest commit:

- Your proof covers every change in the diff.
- Required checks are green.
- Review bots have finished, and each finding is fixed or dismissed with a
  written reason. A bot asking for "human review" doesn't block when you have
  high confidence in the change.
- No human review still requests changes.
- The branch is up to date with the default branch, and GitHub reports it
  mergeable.

## Asking the user

A question in a normal message goes unseen, and the thread looks done. Ask
with the harness's question tool (`AskUserQuestion` in Claude Code,
`request_user_input` in Codex), so the thread shows it is waiting. Put all the
context in the question: the PR link, what blocks you, and the options with
your recommendation first.

Ask only when you can't continue alone:

- You can't prove the change.
- The merge gate can't pass, and you can't fix that yourself.
- The next step is outside the permissions above: deleting data, touching
  production, changing things outside the repo, closing a PR, or force-pushing
  any other branch.
- The goal is ambiguous in a way that changes the result.
- Another PR makes this one obsolete.

Decide everything else yourself, and list those decisions in the report.

If there is no question tool, or it returns no answer, leave the PR open and
unmerged and start your final message with the question.
