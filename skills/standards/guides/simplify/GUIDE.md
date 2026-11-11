# Simplify

Make a working change as small and simple as it can be while it still fixes
something a user would notice. Use it on your own diff, on someone else's PR,
or as the brief for a subagent.

The goal is the smallest diff that still fixes the bug. Behavior a user would
notice must not regress. Code that only handles what can't happen goes.

## 1. Name the impact

Before touching code, write one sentence for each problem the change fixes:

- who hits it: which user, on which screen, device, or job;
- what they see: the wrong result, the stuck spinner, the lost edit;
- how often: every visit, on startup, only under a race between two writes.

Keep the one or two that matter. Anything theoretical, a race no user would
notice, or "defense in depth" gets cut, along with the code that handles it.

Check who actually runs the code. If one person uses the app, or you ship
every client together, there's no backward compatibility to keep. Size
concurrency handling to the callers that really exist.

## 2. Prove each one on the base branch

Reproduce each named problem on the base branch, not on your branch: a test
that fails there, or a precise trace through the code. If you can't show it
happens, drop it.

## 3. Write the smallest fix

- Prefer deleting or narrowing code to adding it.
- Reuse what the base branch and the project's libraries already have: an
  option, a flag, an existing atom or hook, a plain HTML attribute.
- Add none of these unless the fix is impossible without them. If you add
  one, name the problem from step 1 that comes back without it:
  - a new module or file for one fix;
  - a reducer or state machine;
  - a revision, generation, or attempt counter;
  - a lock, retry, backoff, or queue;
  - a new table, column, or migration;
  - a compatibility path or feature detection;
  - an option bag, wrapper, or one-use helper.
- One focused regression test per named problem. No matrix of orderings and
  races.

## 4. Cut until nothing moves

Reread the diff as a skeptical reviewer. For every added line, file, type,
piece of state, helper, comment, and test, ask: does a named problem come
back without this? If not, delete it.

Then repeat this step on the new diff. Stop when a full pass deletes nothing.

Run the checks after the last pass, and redo the step 2 proof for anything
the cuts touched.

## 5. Decide whether it should exist

If what's left fixes something small, say so and recommend closing the PR or
dropping the change. A small benefit doesn't justify the cost of keeping code.

## 6. Report

- What a user saw before and sees now, in 3-6 plain bullets.
- The size before and after (`+added/-removed`), what you cut, and why.
- The proof from step 2 and the checks you ran.
- Or the recommendation to close, with the evidence.

## As a subagent brief

Point the subagent at this guide and the `standards` skill. Then add what it
can't know:

- the change, its branch, and its base;
- who uses the code, and what ships together;
- the pieces you already suspect, as pointed questions. For example: "Is the
  new table needed, or can this be dropped?" or "Does this lock protect
  against a caller that exists?"
