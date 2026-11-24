# Simplify

Make a working change as small and simple as it can be while it still fixes
something a user would notice. Use it on your own diff, on someone else's PR,
or as the brief for a subagent.

Behavior a user would notice must not regress. Code that only handles what
can't happen goes.

## 1. Name the impact

Before touching code, write one sentence for each problem the change fixes:

- who hits it: which user, on which screen, device, or job;
- what they see: the wrong result, the stuck spinner, the lost edit;
- how often: every visit, on startup, only under a race between two writes.

Keep the one or two that matter. Anything theoretical, a race no user would
notice, or "defense in depth" gets cut, along with the code that handles it.
Size compatibility and concurrency handling to the callers that really exist
(`standards` section 2).

## 2. Prove each one on the base branch

Reproduce each named problem on the base branch, not on your branch: a test
that fails there, or a precise trace through the code. If you can't show it
happens, drop it.

## 3. Write the smallest fix

- Follow `standards` sections 1 and 2: reuse what the base branch and the
  project's libraries already have, and prefer deleting or narrowing code to
  adding it.
- Add no machinery from `standards` section 5 unless the fix is impossible
  without it. If you add one, name the problem from step 1 that comes back
  without it.
- One focused regression test per named problem. No matrix of orderings and
  races.

## 4. Cut until nothing moves

Reread the diff as a skeptical reviewer. For every added line, file, type,
piece of state, helper, comment, and test, ask: does a named problem come back
without this? If not, delete it.

Repeat on the new diff until a full pass deletes nothing. Then run the checks,
and redo the step 2 proof for anything the cuts touched.

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
- the pieces you already suspect, as pointed questions: "Is the new table
  needed, or can this be dropped?"
