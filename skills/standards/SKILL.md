---
name: standards
description: Code quality standards for writing, simplifying, reviewing, testing, and debugging code. Use whenever you write or change code, before filing or updating a PR, when reviewing a diff or PR, when the user asks to simplify or clean up, wants test-first development (TDD, red-green-refactor), or reports a bug, failure, or slowdown to diagnose.
---

# Standards

These rules apply to every change. They are judgment calls, not lint rules, so
think about each one in context.

The repo's own conventions, lint config, and instruction files come first.
Where they conflict with this skill, the repo wins. If the repo has its own
skills (in `.claude/skills`, `.agents/skills`, or `skills/`), read the ones
that cover the area you're changing.

Every change has two goals, and the second matters as much as the first:

1. Fix the bug or build the feature.
2. Leave the codebase clean: easy to understand, easy to build on, with fewer
   places for bugs to hide.

A change that meets the first goal by hurting the second is not done.

There are three modes. Each is scoped to the diff and the code it touches.
Unrelated code is a follow-up, not part of this change.

- **Writing:** follow the rules while you make the change.
- **Simplify pass:** once the change works, follow `guides/simplify/GUIDE.md`
  on the diff, then re-run the checks.
- **Review:** check a diff against the rules and report findings. See "Review
  output".

## Guides

Read the guide in full before you start. These rules still apply inside it.

| Task | Guide |
| --- | --- |
| Build a feature or fix a bug test-first | `guides/tdd/GUIDE.md` |
| Diagnose a hard bug, a failure, or a performance regression | `guides/diagnosing-bugs/GUIDE.md` |
| Simplify a change or PR until it's as small as it can be | `guides/simplify/GUIDE.md` |

## 0. Start from what a user would see

Every fix and every finding starts with one sentence: who hits the problem,
what they see, and how often. Prove it happens on the base branch, with a
failing test or a precise trace, before you fix it.

A finding no user would notice is a nit at most. Don't fix it in this change.
Hunting for a pattern ("find every race") finds candidates. It isn't a reason
to fix each one.

## 1. Choose the right solution

- **Look for what already exists.** Before you write new code, check whether a
  library the project uses already has an option or function for this, and
  whether the repo solves the same problem somewhere else.
- **Step back once it works.** Is this the simple, right solution for this
  repo, or a workaround on top of the real problem? If it's wrong, change it,
  even if that throws away work.
- **Notice when you're stuck on one path.** Patching symptom after symptom, a
  diff that keeps growing, or fighting the framework all mean the approach is
  probably wrong. Stop and look for another.

## 2. Keep the change focused

- **Handle the cases that can really happen,** especially one that would turn
  into a bug later. Don't write code for cases that can't happen or are very
  unlikely. When you leave one out on purpose, know why.
- **Prefer deleting or narrowing code over adding it.** A fix that removes
  lines is usually the right one.
- **Scale to the real deployment.** Check who actually runs the code. If one
  person uses it, or every client ships together, there is no backward
  compatibility to keep. Handle the concurrency real callers create, not every
  interleaving that's possible in theory.
- **Decide what belongs in this PR.** If the change is wrong or incomplete
  without something, fix it here. A separate improvement (another path, a rare
  case, a small cost) is a follow-up PR.

## 3. Things that change together belong together

Ask of every piece the change touches: **should these pieces change
together?** Code gets it wrong in three ways.

**Hidden links:** pieces that must change together, where nothing shows it.

- Copies of logic or values. Keep one source and derive the rest.
- A module that reads a global or a file that another module sets. Pass the
  value in.
- One feature spread across folders by layer. Put a feature's code together.
- A call order or convention that callers just have to know. Make the API
  enforce it with types, one entry point, or a required argument.

**Needless links:** pieces tied together that change for different reasons.

- Callers that reach into another module's internals. Give them an interface.
- Stable code that imports more volatile code. Dependencies point toward what
  changes less.
- A general function with a parameter only one caller understands. Move that
  knowledge into the caller.
- A shallow module whose interface mirrors its internals. The interface should
  be smaller than what it hides.

**Surplus:** pieces with no reason of their own to change. See section 4.

When unsure, `git log` shows which files actually change together.

## 4. Remove, don't preserve

When a change makes something unnecessary, delete it in the same change.

- **No compatibility shims.** When you change an API, update its callers.
  Don't keep the old name as a wrapper, alias, re-export, or deprecated
  overload.
- **No do-nothing code.** Delete identity functions, pass-through wrappers,
  empty handlers, and helpers that only forward their arguments. "Callers
  still use it" is a reason to update the callers.
- **No speculative generality.** No extension points, options, or config for
  things that don't vary.
- **Delete branches that can no longer happen:** a removed platform, a retired
  flag, an old data shape. Delete their setup too.
- **Delete what nothing uses:** exports, files, dependencies, types, options,
  parameters, and comments or docs that describe removed behavior.

## 5. Special cases point at missing design

A special case is code that exists for one situation instead of following
from how the system works:

- an `if` for one value, or a parameter for one caller;
- a swallowed exception;
- a retry or a sleep;
- a disabled or skipped test.

Machinery is a special case too. Add none of these without naming the problem
from section 0 that comes back without it:

- a new module or file for one fix;
- a reducer or state machine;
- a revision, generation, or attempt counter;
- a lock, retry, backoff, or queue;
- a new table, column, or migration;
- a compatibility path or feature detection;
- an option bag, wrapper, or one-use helper.

Before you add one, look for the general fix that makes it unnecessary. When
several special cases share a cause, fix the cause once. If that fix is bigger
than this change, make the small fix and list the structural one as a
follow-up.

## 6. Shape

- **Narrow early.** Parse and validate at the boundary, and handle edge cases
  up front with early returns. The rest of the code sees one shape and runs
  one path. Don't carry optional or loosely typed values deep into the code
  and branch on them there.
- **Be careful with mode arguments.** A boolean, enum, or `kind` option that
  picks between code paths is fine when the paths share most of their code.
  When the function is mostly `if (kind === ...)` branches, split it into
  explicit functions that share the common parts. Ordinary data arguments (an
  ID, a limit, `disabled`) are fine.
- **Fewer layers.** A module with one caller and no concept of its own belongs
  in that caller. Don't add an abstraction until a second real use exists.
- **Keep abstractions that name a real concept** callers rely on. Fold a layer
  in only when it adds nothing.
- **One way to do a thing.** Extend or replace the existing path. Don't add a
  second one next to it.

## 7. State

- **Add as little state as possible.** Before adding a state variable or store
  field, name the independent fact it holds. If you can compute the value from
  data you already have, compute it where you need it.
- **Store IDs, not copies.** Keep `selectedUserId` and look the user up in the
  data you already fetched. A copied object goes stale.
- **Don't mirror server data.** Fetched data lives in its fetch cache, not in
  a store, a context, or local state.

## 8. Types

The type system should make invalid states fail to compile.

- **Discriminated unions over flag bags.** `{ status: "error"; error: E }`, not
  `{ loading?: boolean; error?: E; data?: T }`.
- **Exhaustive switches.** Switch on a union with no `default`, and end with
  `value satisfies never`, so a new variant fails to compile until every
  switch handles it.
- **Brand primitives** that can be mixed up (IDs, emails, money). Validate
  once at the boundary, and let downstream code trust the type. Use the
  project's library for this when it has one.
- **Derive, don't restate.** Use `Pick`, `Omit`, `ReturnType`, `Awaited`,
  `typeof`, and schema inference before writing an interface that copies an
  existing shape.
- **Let types flow end to end.** Database, server, and client share types
  through the project's end-to-end tool. Never copy a type across a boundary
  by hand.
- **Typed errors.** Expected failures are typed values in the error channel,
  not thrown exceptions. Map them to the caller's vocabulary at each boundary,
  exhaustively, so a new error fails to compile. Wrap code that can throw so
  its failure gets a type. Only real bugs stay untyped.
- **Identify errors by a stable code** (a `_tag` or `code`), never by message
  text. Don't collapse them into one "Something went wrong": the user needs to
  know what failed and what to do.
- **No escape hatches** (`any`, `as`, `!`, `@ts-ignore`) without a comment
  saying why the type system can't express it.
- **Pass an object** instead of several positional arguments of the same type,
  except on hot paths.

## 9. APIs and data flow

- **Put logic on the server when it can run there.** Shape an endpoint around
  what the screen needs. If the client must wait for one response to make the
  next request, add one endpoint that returns both.
- **Reads have no side effects.** A query can be retried, refetched on focus,
  or run twice. It must never start work or change state. Anything that
  changes state is a mutation, even if it's idempotent.
- **One outcome, one write.** Dependent writes for one user action belong in
  one server operation, with a transaction or explicit partial-failure
  handling. Don't make the client run a create, check, start sequence.
- **Return explicit shapes.** Pick the fields instead of returning database
  rows, so private ones can't leak. Check authorization in the service, not
  the client.

## 10. Configuration

- **Use the repo's config module.** If the repo has a typed entry point that
  reads and validates the environment, read config through it and add new
  values there. Don't scatter `process.env` reads.
- **Required secrets have no fallback.** A missing secret fails at startup.
  Defaults are only for optional values.
- **Keep server secrets and browser config in separate entry points,** so a
  secret can't end up in a client bundle.
- **No inline URLs or paths.** Define each origin, base path, and endpoint
  once, and derive related ones from it.

## 11. React and UI code

- **Don't manage promise state by hand.** No `setLoading(true)`, `await`,
  `setError()` sequences in a component or hook. Use the query library
  (`useQuery`, `useMutation`) or `useTransition`, and read their state.
- **Effects are a last resort.** Most effects are one of these, and each has a
  better tool:
  - A value computed from props or state: compute it during render.
  - Fetching: use the query library. It handles races, caching, and retries.
  - Reacting to a click or submit: do the work in the event handler.
  - Resetting state when an ID changes: render the component with `key={id}`.
  - Waiting for something to be ready: render the component only once it is,
    so its effect runs once on mount instead of watching a flag.

  Use an effect only to sync with something outside React (a subscription, a
  DOM API, a third-party widget), and return a cleanup. When it should run
  once on mount, call a `useMountEffect(fn)` helper that wraps
  `useEffect(fn, [])`. Use the repo's helper if it has one.
- **In review, every new `useEffect` is a should.** Name which case above it
  is and give the replacement. The only exception is an effect that syncs with
  something outside React and cleans up.
- **Check for data before checking status.** If data exists, show it, even
  while refetching or after a refresh fails, with the error next to it. Show a
  skeleton only on the first load.
- **Empty is not loading.** An empty list is a successful result and gets the
  empty state. A query that hasn't started (missing input, disabled) isn't
  loading either.
- **No mode booleans that choose whole trees** (`isNewChat`, `isNative`).
  Compose explicit trees from shared parts. Booleans that describe state
  (`disabled`, `selected`) are fine.
- **Don't touch browser globals** (`window`, `localStorage`) at module load or
  during a server render.

## 12. Clarity

- Reduce nesting. Prefer early returns to `else` chains.
- No nested ternaries. Use `if`/`else` or `switch` for more than two cases.
- Choose clear over short. No dense chains that have to be decoded.
- Name things for what they are, in the domain's words. Rename when the
  meaning changes.
- **Remove comments that restate the code,** even ones phrased as a why, like
  `// sort first so the binary search works`.
- **Keep comments about facts outside the code,** like `// the proxy drops
  websockets, so we poll`. A comment explaining a workaround goes away when
  the problem behind it does.

## 13. Tests and proof

A test should fail when behavior regresses, and only then.

- **Remove tests that restate the code** (a lookup table, a mapping, a mock
  that replays the implementation) and tests that can't fail.
- **Tie tests to behavior, not internals.** A refactor that keeps behavior
  should not break a test.
- **Use real dependencies when you can run them:** a real database, a local
  emulator, the real runtime. Mock only third-party services with no test
  environment.
- **Avoid sleeps.** Wait for a condition or control the clock. To test a
  loading or error state, hold the request open and release it when the test
  is ready. If a sleep is the only option, keep it short and say why.
- **For a bug fix,** add one focused test that fails without the fix, when the
  repo has a test setup and nothing covers the behavior. One test per real
  problem: no matrix of orderings and edge cases unless a user could hit each
  row.
- **Prove what you claim.** "It works" means you saw it work in this session:
  command output, a reproduction, a screenshot. Green mocked tests don't prove
  a user-facing flow, and a tool listed in `package.json` doesn't prove it
  ran.

## 14. Observability and performance

- Instrument with structured spans or one wide event per unit of work, not
  scattered print logs. Keep the cause on every error you wrap.
- A performance claim needs the mechanism and the measured size of the effect.
  "This should be faster" is not a reason to add complexity.

## 15. Checks

- **Don't silence a check to make it pass.** Don't disable a lint rule, skip a
  test, raise a threshold, or add a cast. Fix the cause. If you must suppress
  something, scope it to one line and say why.
- **Turn repeats into checks.** If a finding is mechanical, propose a lint
  rule, a type test, or a CI check that would catch it next time.

## Review output

Report each finding with the rule it breaks:

```
[blocker|should|nit] <file>:<line> <what is wrong>. Rule: <section>. Fix: <smallest fix>.
```

- **blocker:** the intended case is wrong.
- **should:** a real bug callers will hit, or a violation that makes the code
  harder to change (a hidden link, a shim, a dead branch, a lost type, a test
  that proves nothing, machinery no named problem needs).
- **nit:** everything else.

A blocker or should about behavior names the scenario: the steps a user or
caller takes and what goes wrong. Without one, it's a nit.

Also list code the change could delete and still do its job. Each deletion is
a should. When several findings share one cause, report the cause once, with
the one fix that resolves them all.

Lead with blockers. If the diff is clean, say so in one line. Don't invent
findings to fill a review.
