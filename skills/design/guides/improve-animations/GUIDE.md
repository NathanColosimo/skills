# Improving animations

Survey a codebase's animation and motion code, find the fixes worth making,
and write a plan for each one that another agent, even a weaker model, can
carry out without any taste of its own.

This guide audits and plans. The audit never changes source code. Code
changes only when the user asks you to run a plan (see "Running a plan"). It
doesn't review a single diff; for that, use the
[review-animations guide](../review-animations/GUIDE.md). What to look for is
in [AUDIT.md](AUDIT.md), the values are in
[../review-animations/STANDARDS.md](../review-animations/STANDARDS.md), and
the plan format is in [PLAN-TEMPLATE.md](PLAN-TEMPLATE.md).

## Rules

1. **The audit writes only plans.** Write under `plans/`, or
   `animation-plans/` if `plans/` is already used for something else. If the
   user asks you to just fix it, write the plan, then run it.
2. **Audit read-only.** While auditing, no installs, builds with side
   effects, commits, or formatters.
3. **Make every plan self-contained.** The executor has none of this
   conversation. Never write "use the easing discussed above". Write the exact
   curve, duration, file path, and code excerpt.
4. **Respect settled decisions.** If a doc or comment explains a deliberate
   motion trade-off, leave it alone.

## 1. Recon

Map the motion before judging it:

- **Stack:** framework, motion libraries (Motion, React Spring, GSAP, plain
  CSS, Web Animations API), component libraries (Radix, Base UI, shadcn/ui).
- **Where motion lives:** global CSS and tokens (`--ease-*`, `--duration-*`),
  Tailwind config, keyframes, `transition` and `animate` props, gesture
  handlers.
- **Conventions:** existing easing tokens, duration scales, and spring configs.
  Plans extend these; they don't add parallel ones.
- **Personality:** a playful consumer app or a crisp dashboard. Cohesion
  findings depend on it.
- **Frequency:** which animated elements are hit 100+ times a day, which
  occasionally, which rarely. This sets severity.

Useful searches: `transition`, `animation`, `@keyframes`, `motion.`,
`animate={`, `useSpring`, `ease-in`, `transition: all`, `scale(0)`,
`prefers-reduced-motion`, `transform-origin`.

## 2. Audit

Check the eight categories in AUDIT.md. In a large repo, split the work across
read-only subagents, one per category or per app area. Give each one the path
to AUDIT.md and the category heading, the recon facts, and an instruction to
return findings only, as `file:line` with evidence and no fixes.

Pick a depth (default `standard`):

| Depth | Covers | Subagents | Findings |
| --- | --- | --- | --- |
| `quick` | High-traffic components only | 0-1 | About 5, HIGH only |
| `standard` | All interactive UI | Up to 4 | Full table |
| `deep` | The whole repo, including marketing pages | Up to 8 | Full table, including LOW polish |

## 3. Vet, rank, and confirm

Re-read the cited code for every finding yourself. Drop anything that's
deliberate, misattributed, duplicated, or correct by exception (a centered
modal, a long animation on a marketing page). Never report a finding you
haven't confirmed at its `file:line`.

Show the findings in one table, ordered by impact divided by effort:

| # | Severity | Category | Location | Finding | Fix summary |
| --- | --- | --- | --- | --- | --- |

- **HIGH:** breaks the feel: `ease-in` on UI, animation on keyboard or
  high-frequency actions, dropped frames, `scale(0)`.
- **MEDIUM:** noticeably off: wrong origin, non-interruptible dynamic UI,
  missing reduced-motion handling.
- **LOW:** polish: stagger, blur over crossfades, consolidating tokens.

After the table, list 2-4 missed opportunities separately, since they add
motion rather than fix it.

Then wait for the user to choose which findings become plans. If nobody is
around to choose, take the top 3-5.

"The motion here is already right" is a valid result. When you can't judge the
feel from code (a crossfade, a spring's bounce), say so and put a feel check in
the plan.

## 4. Write plans

Write one plan per chosen finding, following PLAN-TEMPLATE.md, as
`plans/NNN-short-slug.md`. Number them after any existing plans. Stamp each
with the current commit (`git rev-parse --short HEAD`).

Then create or update `plans/README.md` with a table of plans (number, title,
severity, status), the order to run them in, and any dependencies.

## Narrower requests

- **Depth only** (`quick` or `deep`): change the audit depth. Works with a
  focus.
- **One category** (performance, accessibility, easing): recon, then audit only
  that category.
- **One known fix:** skip the audit, recon just enough to be specific, and
  write a single plan.
- **Reconcile:** re-check `plans/` against the current code. Mark finished
  plans DONE, refresh stale `file:line` references, and retire fixed findings.

## Running a plan

To carry out a plan, hand it to a subagent or another agent in a separate
checkout or worktree. It follows the plan's steps and boundaries. When it
finishes, review its diff against the
[review-animations guide](../review-animations/GUIDE.md) and give a verdict.
