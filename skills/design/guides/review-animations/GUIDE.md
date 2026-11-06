# Reviewing animations

Review animation and motion code against a high bar. Motion that runs but
feels sluggish, starts from the wrong place, fires too often, or drops frames
is a regression. Flag by default; approval is earned.

This guide reviews motion only. The exact values to cite are in
[STANDARDS.md](STANDARDS.md); use them instead of approximating.

## The ten standards

Measure every animation in the diff against these. A violation is a finding.

1. **It has a purpose:** feedback, spatial consistency, state indication,
   explanation, or preventing a jarring change. Decorative motion on something
   seen often is a block.
2. **It fits the frequency.** No animation on keyboard-initiated or 100+ a day
   actions. Less motion on things seen tens of times a day. Delight only on
   rare moments.
3. **Responsive easing.** Entrances and exits use `ease-out` or a strong custom
   curve. `ease-in` on UI is a block.
4. **UI animations stay under 300ms,** unless there's a stated reason.
5. **Physically correct.** Popovers, dropdowns, and tooltips scale from their
   trigger. Nothing starts from `scale(0)`. Modals stay centered.
6. **Interruptible.** Rapid or gesture-driven motion (toasts, toggles, drags)
   uses transitions or springs, not keyframes.
7. **GPU-only.** Only `transform` and `opacity` animate.
8. **Accessible.** `prefers-reduced-motion` is handled (gentler, not zero), and
   hover motion is gated behind `@media (hover: hover) and (pointer: fine)`.
9. **Asymmetric where it should be.** Deliberate actions (a press, a hold, a
   destructive confirm) go slow; the system's response snaps.
10. **Cohesive.** Motion matches the component and the rest of the product.
    When unsure whether motion feels right, deleting it is often the best fix.

## Flag on sight

- `transition: all`
- `scale(0)`, or a fade-in with no starting transform
- `ease-in` on any UI interaction, or a weak built-in curve on a deliberate
  animation
- animation on a keyboard shortcut, a command palette, or a 100+ a day action
- a UI duration over 300ms with no reason given
- `transform-origin: center` on a popover, dropdown, or tooltip
- keyframes on toasts, toggles, or anything triggered rapidly
- animated `width`, `height`, `margin`, `padding`, `top`, or `left`
- Motion `x`/`y`/`scale` props before `motion` 14.2, or layout animations,
  running while the page is busy
- a CSS variable on a parent driving a child's transform
- movement with no `prefers-reduced-motion` handling
- ungated `:hover` motion
- the same timing for press and release on a hold or press interaction
- a group that appears all at once where a 30-80ms stagger belongs

## Prefer fixes in this order

1. Delete the animation.
2. Reduce it: shorter, smaller, fewer properties.
3. Fix the easing.
4. Fix the origin: correct `transform-origin`, `scale(0.95)` with opacity
   instead of `scale(0)`.
5. Make it interruptible: keyframes to transitions, or a spring for gestures.
6. Move it to the GPU: layout properties to `transform`/`opacity`.
7. Make the timing asymmetric.
8. Polish: blur over a crossfade, stagger groups, `@starting-style` for entry,
   springs for elements that should feel alive.
9. Add reduced-motion and hover gating, and tune to the product's personality.

Use CSS transitions, `@starting-style`, or the Web Animations API for fixed
motion, and JavaScript or springs for dynamic, interruptible, or gesture-driven
motion.

## Output

### 1. Findings table

One table, one row per issue. Cite `file:line`.

| Before | After | Why |
| --- | --- | --- |
| `transition: all 300ms` | `transition: transform 200ms ease-out` | `all` animates properties you didn't intend, off the GPU |
| `transform: scale(0)` | `transform: scale(0.95); opacity: 0` | Nothing should appear from nothing |
| `ease-in` on dropdown | `ease-out` with a custom curve | `ease-in` delays the moment the user is watching |
| `transform-origin: center` on popover | `var(--transform-origin)` (Base UI) | Popovers grow from their trigger; only modals stay centered |

### 2. Verdict

Group any other comments by impact, highest first, and leave out empty groups:

1. Feel-breaking regressions: sluggish easing, motion from nowhere, animation
   on keyboard or high-frequency actions.
2. Animations to remove or cut down.
3. Performance: non-GPU properties, dropped frames, style recalculation.
4. Interruptibility and timing.
5. Origin, physical correctness, and cohesion.
6. Accessibility.

End with a decision:

- **Block** for any feel-breaking regression, animation on a keyboard or
  high-frequency action, `scale(0)` or `ease-in` on UI, or a non-GPU animation
  with an easy GPU fix.
- **Approve** when none of those remain, nothing obviously should be deleted,
  durations and easing are in range, interruptibility is handled where
  needed, and reduced motion is respected.

When you can't judge the feel from code, say so and recommend a slow-motion or
next-day check (see "Checking how it feels" in STANDARDS.md).
