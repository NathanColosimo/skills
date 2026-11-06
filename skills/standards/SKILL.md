---
name: standards
description: Code quality standards for writing, simplifying, reviewing, testing, and debugging code. Use whenever you write or change code, before filing or updating a PR, when reviewing a diff or PR, when the user asks to simplify or clean up, wants test-first development (TDD, red-green-refactor), or reports a bug, failure, or slowdown to diagnose.
---

# Standards

These rules apply to every change. They are judgment calls, not lint rules: a
linter already catches what it can. Think about each one in context instead
of applying it mechanically.

Follow the repo's own conventions, lint config, and instruction files first.
Where they conflict with this skill, the repo wins. If the repo has its own
skills (for example in `.claude/skills`, `.agents/skills`, or `skills/`),
read the ones that cover the area you're changing before you start.

Every change has two goals, and the second matters at least as much as the
first:

1. Fix the bug or build the feature.
2. Leave the codebase clean, easy to understand, easy to build on, and with
   fewer places for bugs to hide.

A change that meets the first goal by hurting the second is not done.

There are three modes:

- **Writing:** follow the rules while you make the change.
- **Simplify pass:** once the change works, reread your diff against the rules
  and fix what you find, starting with section 1. Behavior must stay the same.
  Re-run the checks.
- **Review:** check a diff against the rules and report findings. See "Review
  output".

Scope every mode to the diff and the code it touches. Do not rewrite unrelated
code. Note it as a follow-up instead.

## Guides

Two workflows have their own guides in this skill's folder. Read the guide in
full before you start:

| Task | Guide |
| --- | --- |
| Build a feature or fix a bug test-first | `guides/tdd/GUIDE.md` |
| Diagnose a hard bug, a failure, or a performance regression | `guides/diagnosing-bugs/GUIDE.md` |

These rules still apply inside a guide's workflow.

## 1. Choose the right solution

It's easy to commit to the first idea and keep pushing it, even when it's the
wrong fix or a hand-rolled version of something that already exists.

- **Look for what already exists.** Before you write new code, check whether a
  library the project already uses has an option, a flag, or a function that
  does this. Read its docs and types. Check whether the repo already solves
  the same problem somewhere else.
- **Step back once it works.** Ask whether this is the simple, right solution
  for this repo, or a workaround on top of the real problem. If it's the
  wrong one, change it, even if that means throwing away work.
- **Notice when you're stuck on one path.** Patching symptom after symptom, a
  diff that keeps growing, or fighting the framework all mean the approach is
  probably wrong. Stop and look for a different one.

## 2. Keep the change focused

- **Think through which cases can really happen.** Handle every case that can
  occur in practice, especially one that would turn into a bug later. Don't
  write code for cases that can't happen or are very unlikely. When you leave
  a case out on purpose, know why.
- **Prefer deleting or narrowing code over adding code.** A fix that removes
  lines is usually the right one.
- **Decide what belongs in this PR.** Review can find something that really is
  part of the change, and then the change should grow. For each finding, ask
  whether this change is wrong or incomplete without it. If it is, fix it
  here. If it's a separate improvement (another path, a rare case, a small
  cost), make it a follow-up PR.

## 3. Things that change together belong together

Ask of every piece the change touches: **should these pieces change
together?** The code gets it wrong in three ways.

**Hidden links:** pieces that must change together, where nothing shows it.

- Copies of logic or values. Keep one source and derive the rest from it.
- A module that reads a global, or a file, that another module sets. Pass the
  value in explicitly.
- One feature spread across folders by layer. Put a feature's code together.
- A call order or convention that callers just have to know. Make the API
  enforce it with types, one entry point, or a required argument.

**Needless links:** pieces tied together that change for different reasons.

- Callers that reach into another module's internals. Give them an interface.
- Stable code that imports more volatile code. Dependencies point toward what
  changes less.
- A general function with a parameter that only one caller understands. Move
  that knowledge into the caller.
- A shallow module whose interface mirrors its internals, so callers change
  whenever it does. The interface should be smaller than what it hides.

**Surplus:** pieces with no reason of their own to change. See section 4.

`git log` shows which files actually change together. Use it as evidence when
you're unsure.

## 4. Remove, don't preserve

When a change makes something unnecessary, delete it in the same change.

- **No compatibility shims.** When you change an API, update its callers. Do
  not keep the old name as a wrapper, alias, re-export, or deprecated overload.
- **No do-nothing code.** Delete identity functions, pass-through wrappers,
  empty handlers, and helpers that only forward their arguments. "Callers still
  use it" is a reason to update the callers, not to keep it.
- **No speculative generality.** No extension points, options, or config for
  things that don't vary.
- **Delete branches that can no longer happen.** If a condition can't occur
  anymore (a removed platform, a retired flag, an old data shape, an
  environment that no longer exists), delete the branch and its setup.
- **Delete what nothing uses.** Unused exports, files, dependencies, types,
  options, and parameters go. So do comments and docs that describe removed
  behavior.

## 5. Special cases point at missing design

A special case is code that exists for one situation instead of following
from how the system works:

- an `if` for one value;
- a parameter for one specific caller;
- a swallowed exception;
- a retry or a sleep;
- a disabled or skipped test.

Before you add one, look for the general fix that makes it unnecessary. When
several special cases share a cause, fix the cause once instead of patching
each one. The right fix often looks nothing like the symptoms. If that fix is
bigger than this change, make the small fix and list the structural one as a
follow-up.

## 6. Shape

- **Narrow early.** Parse and validate at the boundary, then handle the edge
  cases up front with early returns. The rest of the code should see one shape
  and run one path. Do not carry optional or loosely typed values deep into the
  code and branch on them there.
- **Be careful with mode arguments.** A boolean, enum, or `kind` option that
  picks between code paths, like `attach({ kind: "terminal" | "computer" })`,
  is fine when the paths share most of their code and differ in one small
  step. When the function becomes mostly `if (kind === ...)` branches, split
  it into explicit functions or components that share the common parts.
  Ordinary data arguments (an ID, a limit, `disabled`) are fine.
- **Fewer layers.** A module with one caller and no concept of its own belongs
  in that caller. Do not add an abstraction until a second real use exists.
- **Keep abstractions that name a real concept.** Folding code in is right when
  the layer adds nothing. It is wrong when the layer gives a name to an idea
  that callers rely on.
- **One way to do a thing.** Do not add a second path next to an existing one.
  Extend or replace the existing one.

## 7. State

- **Add as little state as possible.** Before adding a state variable or store
  field, name the independent fact it holds. If you can compute the value from
  data you already have, compute it where you need it.
- **Store IDs, not copies.** Keep `selectedUserId`, then look the user up in
  the data you already fetched. A copied object goes stale.
- **Don't mirror server data.** Fetched data lives in its fetch cache. Do not
  copy it into a store, a context, or local state.

## 8. Types

The type system should make invalid states fail to compile.

- **Discriminated unions over flag bags.** `{ status: "error"; error: E }`, not
  `{ loading?: boolean; error?: E; data?: T }`.
- **Exhaustive switches.** Switch on a union with no `default` case, and end
  with `value satisfies never`, so adding a variant fails to compile until
  every switch handles it.
- **Brand primitives** that can be mixed up (IDs, emails, money). Validate once
  at the boundary. Downstream code trusts the type. Use the project's library
  primitives for this when it has them.
- **Derive, don't restate.** Use `Pick`, `Omit`, `ReturnType`, `Awaited`,
  `typeof`, and schema inference before you write a new interface that copies
  an existing shape.
- **Let types flow end to end.** Database, server, and client should share types
  through the project's end-to-end tool. Never copy a type across a boundary by
  hand.
- **Typed errors.** Expected failures are typed values in the error channel, not
  thrown exceptions. Map them to the caller's vocabulary at each boundary, and
  make that mapping exhaustive so a new error fails to compile. Wrap code that
  can throw so its failure gets a type. Only real bugs should stay untyped
  defects.
- **Identify errors by a stable code** (a `_tag` or `code`), never by matching
  message text. Don't collapse typed errors into one "Something went wrong";
  the user needs to know what failed and what to do.
- **No escape hatches** (`any`, `as`, `!`, `@ts-ignore`) without a comment that
  says why the type system can't express it.
- **Pass an object** instead of several positional arguments of the same type,
  except on hot paths.

## 9. APIs and data flow

- **Put logic on the server when it can run there.** Shape an endpoint around
  what the screen needs. If the client must wait for one response to make the
  next request (fetch the user, then fetch their teams), add one endpoint that
  returns both.
- **Reads have no side effects.** A query can be retried, refetched on focus,
  or run twice by two components. It must never start work or change state.
  Anything that changes state is a mutation, even if it's idempotent.
- **One outcome, one write.** Dependent writes for a single user action belong
  in one server operation, with a transaction or explicit partial-failure
  handling. Don't make the client run a create, check, start sequence.
- **Return explicit shapes.** Don't return database rows directly; pick the
  fields so private ones can't leak. Check authorization in the service, not
  the client.

## 10. Configuration

- **Use the repo's config module.** If the repo has a typed entry point that
  reads and validates the environment, read config through it and add new
  values there. Don't scatter `process.env` reads through the code.
- **Required secrets have no fallback.** A missing secret fails at startup.
  Defaults are only for optional values.
- **Keep server secrets and browser config in separate entry points,** so a
  secret can't end up in a client bundle.
- **No inline URLs or paths.** Define each origin, base path, and endpoint once
  as a named constant or config value, and derive related ones from it.

## 11. React and UI code

- **Don't manage promise state by hand.** No `setLoading(true)`, `await`,
  `setError()` sequences, in a component or a custom hook. Use the query
  library (`useQuery`, `useMutation`) or `useTransition`, and read their state
  directly.
- **Effects are a last resort.** Most effects are one of these, and each has a
  better tool:
  - A value computed from props or state: compute it during render. Setting
    state from an effect costs an extra render with stale data.
  - Fetching: use the query library. It handles races, caching, and retries.
  - Reacting to a click or submit: do the work in the event handler. Don't set
    a flag for an effect to notice.
  - Resetting state when an ID changes: render the component with
    `key={id}` so it starts fresh.
  - Waiting for something to be ready: render the component only once it's
    ready, so its effect runs once on mount instead of watching a flag.

  Use an effect only to sync with something outside React (a subscription, a
  DOM API, a third-party widget), and return a cleanup.
- **Check for data before checking status.** If data exists, show it, even
  while refetching or after a refresh fails. Show the refresh error next to
  the content. Show a skeleton only on the first load, when there is no data.
- **Empty is not loading.** An empty list is a successful result and gets the
  empty state. A query that hasn't started (missing input, disabled) isn't
  loading either, so don't show a spinner that never ends.
- **No mode booleans that choose whole trees** (`isNewChat`, `isNative`).
  Compose explicit trees from shared parts. Booleans that describe state
  (`disabled`, `selected`) are fine.
- **Don't touch browser globals** (`window`, `localStorage`) at module load or
  during a server render.

## 12. Clarity

- Reduce nesting. Prefer early returns to `else` chains.
- No nested ternaries. Use `if`/`else` or `switch` for more than two cases.
- Choose clear over short. No clever one-liners or dense chains that have to
  be decoded.
- Use names that say what a thing is, in the domain's words. Rename when the
  meaning changes.

Comments:

- **Remove comments that restate the implementation,** even ones phrased as a
  why, like `// sort first so the binary search works`. They only change when
  the code does.
- **Keep comments about facts outside the code,** like `// the proxy drops
  websockets, so we poll`. The code can't show those.
- **A comment explaining a workaround** goes away when the problem behind the
  workaround does.

## 13. Tests and proof

A test should fail when behavior regresses, and only then.

- **Remove tests that restate the code:** a lookup table, a mapping, a
  constant, or a mock that replays the implementation. They check the code
  against itself.
- **Remove tests that can't fail.** They pass whatever the code does.
- **Rewrite tests tied to internals** so they depend on behavior. A refactor
  that keeps behavior should not break a test.
- **Use real dependencies when you can run them:** a real database, a local
  emulator, the real runtime. Mock only third-party services that have no test
  environment.
- **Avoid sleeps in tests.** A fixed sleep is slow and flaky. Prefer waiting
  for a condition or controlling the clock. To test a loading or error state,
  hold the request open and release it when the test is ready. If a sleep
  really is the only option, keep it short and say why in a comment.
- **For a bug fix,** add one focused test that fails without the fix, when the
  repo has a test setup and nothing covers the behavior.
- **Prove what you claim.** "It works" means you saw it work in this session:
  command output, a reproduction, a screenshot. Green mocked tests do not
  prove a user-facing flow. A tool listed in `package.json` doesn't prove it
  ran; check its output.

## 14. Observability and performance

- Instrument with structured spans or one wide event per unit of work, not
  scattered print logs. Keep the cause on every error you wrap.
- A performance claim needs the mechanism and the size of the effect, measured.
  "This should be faster" is not a reason to add complexity.

## 15. Checks

- **Don't silence a check to make it pass.** Don't disable a lint rule, skip a
  test, raise a threshold, or add a cast to get a green run. Fix the cause. If
  you must suppress something, scope it to one line and say why.
- **Turn repeats into checks.** If a finding is mechanical, propose a lint rule,
  a type test, or a CI check that would catch it next time.

## Review output

Report each finding with the rule it breaks:

```
[blocker|should|nit] <file>:<line> <what is wrong>. Rule: <section>. Fix: <smallest fix>.
```

- **blocker:** the intended case is wrong.
- **should:** a real bug callers will hit, or a standards violation that makes
  the code harder to change (a hidden link, a shim, a dead branch, a lost
  type, a test that proves nothing).
- **nit:** everything else.

When several findings share one cause, report the cause once with the findings
under it, and give the one fix that resolves them all.

Lead with blockers. If the diff is clean, say so in one line. Do not invent
findings to fill a review.
