---
name: standards
description: Code quality standards for writing, simplifying, and reviewing code. Use whenever you write or change code, before filing or updating a PR, when reviewing a diff or PR, or when the user asks to simplify, clean up, or check quality.
---

# Standards

These rules apply to every change. They are judgment calls, not lint rules: a
linter already catches what it can. Follow the repo's own conventions, lint
config, and instruction files first. Where they conflict with this skill, the
repo wins.

There are three modes:

- **Writing:** follow the rules while you make the change.
- **Simplify pass:** once the change works, reread your diff against the rules
  and fix what you find. Behavior must stay the same. Re-run the checks.
- **Review:** check a diff against the rules and report findings. See "Review
  output".

Scope every mode to the diff and the code it touches. Do not rewrite unrelated
code. Note it as a follow-up instead.

## 1. Keep the change small

- Make the smallest change that solves the case that actually happened. Do not
  handle every case that could happen.
- Prefer deleting or narrowing code over adding code. A fix that removes lines
  is usually the right one.
- Do not let review grow the change. A finding about another path, a rare
  case, or a small cost is a follow-up, not part of this PR.

## 2. Remove, don't preserve

When a change makes something unnecessary, delete it in the same change.

- **No compatibility shims.** When you change an API, update its callers. Do
  not keep the old name as a wrapper, alias, re-export, or deprecated overload.
- **No do-nothing code.** Delete identity functions, pass-through wrappers,
  empty handlers, and helpers that only forward their arguments. "Callers still
  use it" is a reason to update the callers, not to keep it.
- **Delete branches that can no longer happen.** If a condition can't occur
  anymore (a removed platform, a retired flag, an old data shape, an
  environment that no longer exists), delete the branch and its setup.
- **Delete what nothing uses.** Unused exports, files, dependencies, types,
  options, and parameters go. So do comments and docs that describe removed
  behavior.

## 3. Shape

- **Narrow early.** Parse and validate at the boundary, then handle the edge
  cases up front with early returns. The rest of the code should see one shape
  and run one path. Do not carry optional or loosely typed values deep into the
  code and branch on them there.
- **Fewer layers.** A module with one caller and no concept of its own belongs
  in that caller. Do not add an abstraction until a second real use exists.
- **Keep abstractions that name a real concept.** Folding code in is right when
  the layer adds nothing. It is wrong when the layer gives a name to an idea
  that callers rely on.
- **One way to do a thing.** Do not add a second path next to an existing one.
  Extend or replace the existing one.

## 4. Types

The type system should make invalid states fail to compile.

- **Discriminated unions over flag bags.** `{ status: "error"; error: E }`, not
  `{ loading?: boolean; error?: E; data?: T }`.
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
- **No escape hatches** (`any`, `as`, `!`, `@ts-ignore`) without a comment that
  says why the type system can't express it.
- **Pass an object** instead of several positional arguments of the same type,
  except on hot paths.

## 5. Clarity

- Reduce nesting. Prefer early returns to `else` chains.
- No nested ternaries. Use `if`/`else` or `switch` for more than two cases.
- Choose clear over short. No clever one-liners or dense chains that have to
  be decoded.
- Use names that say what a thing is, in the domain's words. Rename when the
  meaning changes.
- Comments explain why, never what. Delete comments that restate the code.
- Keep related logic together. Do not split one idea across files to make each
  file short.

## 6. Tests and proof

- **Test behavior, not implementation.** A test should fail when the behavior
  breaks and survive a refactor.
- **Don't write tests that restate the code:** a lookup table, a mapping, a
  constant, or a mock that replays the implementation.
- **Use real dependencies when you can run them:** a real database, a local
  emulator, the real runtime. Mock only third-party services that have no test
  environment.
- **For a bug fix,** add one focused test that fails without the fix, when the
  repo has a test setup and nothing covers the behavior.
- **Prove what you claim.** "It works" means you saw it work in this session:
  command output, a reproduction, a screenshot. Green mocked tests do not
  prove a user-facing flow.

## 7. Observability and performance

- Instrument with structured spans or one wide event per unit of work, not
  scattered print logs. Keep the cause on every error you wrap.
- A performance claim needs the mechanism and the size of the effect, measured.
  "This should be faster" is not a reason to add complexity.

## 8. Turn repeats into checks

If a finding is mechanical, propose a lint rule, a type test, or a CI check
that would catch it next time. Rules that a machine can enforce should not
depend on someone remembering them.

## Review output

Report each finding with the rule it breaks:

```
[blocker|should|nit] <file>:<line> <what is wrong>. Rule: <section>. Fix: <smallest fix>.
```

- **blocker:** the intended case is wrong.
- **should:** a real bug callers will hit, or a standards violation that makes
  the code harder to change (a shim, a dead branch, a lost type, a test that
  proves nothing).
- **nit:** everything else.

Lead with blockers. If the diff is clean, say so in one line. Do not invent
findings to fill a review.
