# Diagnosing bugs

For hard bugs and performance regressions. Do the phases in order. Skip one
only when you can say why.

Redact secrets in every command, output, and artifact you show: write
`<REDACTED>` in their place. Keep credentials in environment variables so
they never appear in the commands. Quote only the lines of a captured request
or log that matter. If the redacted output isn't enough to diagnose the bug,
say so and ask the user.

## 1. Build a feedback loop

Most of the work is here. With a fast command that fails on this exact bug,
finding the cause is mechanical. Without one, reading code just produces
guesses.

Ways to build one, roughly in order of preference:

1. A failing test at whatever level reaches the bug.
2. A `curl` or HTTP script against a running dev server.
3. A CLI run on a fixture, diffed against known-good output.
4. A headless browser script that drives the UI and checks the DOM, console,
   or network.
5. A replay of a captured request, payload, or event log through the code
   path.
6. A throwaway harness that runs only the part of the system with the bug.
7. A fuzz loop over many random inputs, for "sometimes wrong" bugs.
8. A `git bisect run` script, when the bug appeared between two known states.
9. A diff of output between the old and new version, or between two configs.
10. Last resort, when a person must click something: copy
    `scripts/hitl-loop.template.sh`, edit its steps, and run it. It walks the
    user through the steps and prints what they report back to you.

Then make the loop better:

- **Faster:** cache setup, skip unrelated startup, run only the relevant test.
- **Sharper:** check the specific symptom, not just "didn't crash".
- **Deterministic:** fix the clock, seed randomness, isolate files and
  network.

For a flaky bug, the goal is a higher failure rate, not a perfect repro. Run
the trigger many times in parallel, add load, or narrow the timing window. A
bug that fails half the time can be debugged. One that fails 1% of the time
can't yet.

If you can't build a loop, stop and say so. List what you tried. Ask the user
for access to an environment where it happens, a captured artifact (a HAR
file, logs, a screen recording), or permission to add temporary production
logging. Don't start guessing at causes without a loop.

**Done when** you have one command that you've run, with its output shown,
and that is:

- aimed at the bug: it runs the real code path and checks the user's exact
  symptom;
- deterministic: same result every run, or a high, steady failure rate for a
  flaky bug;
- fast: seconds, not minutes;
- runnable by you without a person, except through the script in step 10.

## 2. Reproduce and shrink

Run the loop and watch it fail. Check that:

- it fails the way the user described, not with some nearby different bug;
- it fails on every run, or at a steady rate for a flaky bug;
- you've recorded the exact symptom (error, wrong output, timing), so you can
  confirm the fix later.

Then shrink it. Remove inputs, callers, config, data, and steps one at a
time, re-running after each cut. Keep only what the failure needs. You're done
when removing anything else makes it pass. A small repro leaves fewer
suspects and becomes the regression test.

## 3. List hypotheses

Write 3-5 possible causes, ranked, before testing any of them. Stopping at
one anchors you on the first plausible idea.

Each hypothesis needs a prediction you can test: "If X is the cause, then
changing Y will make the bug go away." If you can't state one, sharpen the
hypothesis or drop it.

If the user is around, show them the list before testing. They often know
something that reorders it. Don't wait on an answer.

## 4. Test them

Each probe tests one prediction. Change one thing at a time.

- Prefer a debugger or REPL to logs.
- Otherwise, add targeted logs at the boundaries that tell hypotheses apart.
  Never log everything and search.
- Start every debug log with a unique tag, like `[DEBUG-a4f2]`, so one `grep`
  finds them all for cleanup.

For performance regressions, logs usually mislead. Measure a baseline first
(a timing harness, a profiler, a query plan, a trace), then bisect.

## 5. Fix and add a regression test

Write the regression test before the fix, if there's a place to put it that
exercises the bug the way it really happens. A test that's too shallow (one
caller when the bug needs two, a unit test that can't recreate the chain of
calls) gives false confidence. If no such place exists, report that as a
finding: the code's structure makes the bug hard to lock down.

1. Turn the shrunken repro into a failing test.
2. Watch it fail. If you forced the failure by editing code or a fixture,
   `diff` against the original to confirm your edit took effect.
3. Apply the fix.
4. Watch the test pass.
5. Re-run the original loop from phase 1, on the full scenario.

## 6. Clean up

Before calling it done:

- the original loop no longer fails;
- the regression test passes, or you've written down why there isn't one;
- every `[DEBUG-...]` log is gone (`grep` for the tag);
- throwaway harnesses and prototypes are deleted;
- the commit or PR says what the cause was, so the next person learns it.
