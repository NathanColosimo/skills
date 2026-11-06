# Plan template

Every plan follows this structure. The executor may be a weaker model with none
of your context, so the plan must contain everything, exactly. No references to
"the audit above" or "the easing we discussed".

````markdown
# NNN: <Short imperative title>

- **Status**: TODO
- **Commit**: <output of `git rev-parse --short HEAD` when this was written>
- **Severity**: HIGH | MEDIUM | LOW
- **Category**: <audit category>
- **Scope**: <number of files, rough size>

## Problem

What is wrong, where, and how it affects the feel of the product. Cite every
location as `path/to/file.tsx:123` and paste the current code:

```css
/* src/components/dropdown.css:14, current */
.dropdown { transition: all 400ms ease-in; }
```

## Target

The exact end state, with every value written out: curves, durations, spring
configs, media queries. Never "use a nicer easing":

```css
/* target */
.dropdown {
  transition: transform 200ms var(--ease-out), opacity 200ms var(--ease-out);
  transform-origin: var(--transform-origin);
}
```

## Repo conventions

How this codebase already does it, with one example to copy (token names, file
placement, prop patterns):

- Easing tokens live in `src/styles/tokens.css`; add new curves there, e.g.
  `--ease-out: cubic-bezier(0.23, 1, 0.32, 1);`
- <file:line that already does this correctly>

## Steps

1. <One concrete edit per step: the file, what changes, the resulting code.>
2. ...

## Boundaries

- Don't touch <files or components out of scope>.
- Don't change markup or structure, only motion properties, unless a step says
  otherwise.
- Don't add dependencies.
- If the code doesn't match a step (it changed since the commit stamp), stop
  and report instead of improvising.

## Verification

- **Checks:** <exact commands (typecheck, lint, build) and the expected result>.
- **Feel check:** run the UI, trigger <interaction>, and confirm:
  - <what you should see, e.g. "the dropdown grows from its trigger, not the center">
  - <e.g. "toggling rapidly never restarts the animation from zero">
  - At 10% playback in the DevTools Animations panel, <detail>.
  - With `prefers-reduced-motion` on (DevTools Rendering panel), movement is
    gone but opacity feedback remains.
- **Done when:** <criteria a machine or a person can check>.
````

## Notes for the plan author

- Write one plan per finding. Merge two findings into one plan only when they
  touch the same files with the same fix, like the same token swap across
  components.
- Take every value from
  [../review-animations/STANDARDS.md](../review-animations/STANDARDS.md).
- Always include the feel check. Motion can be mechanically correct and still
  feel wrong, so give the executor, or whoever reviews its diff, specific
  things to watch in slow motion.
