# Animation audit

The eight audit categories and what to look for in each. The exact values to
cite live in [../review-animations/STANDARDS.md](../review-animations/STANDARDS.md);
copy them, never approximate.

## 1. Purpose and frequency

Every animation needs a purpose, and the right amount depends on how often
it's seen. See "Should it animate?" in STANDARDS.md.

Look for:

- animation on keyboard-initiated actions;
- a command palette with an open/close transition;
- decorative motion on list items or hover states the user hits constantly.

The best fix is often to delete the animation.

## 2. Easing and duration

See "Easing" and "Duration" in STANDARDS.md. `ease-in` on UI is always a
finding. Plans add the strong custom curves as tokens, following the repo's
conventions.

Look for:

- `ease-in` anywhere;
- bare `ease` or `linear` on entrances;
- UI durations over 300ms;
- a delay and an animation on every tooltip in a toolbar, where only the
  first should have them.

## 3. Physical correctness

See "Physical correctness" in STANDARDS.md. A centered modal is correct; don't
report it.

Look for:

- `scale(0)`, or fade-ins with no starting transform;
- `transform-origin: center`, or none, on elements anchored to a trigger;
- pressable elements with no press feedback.

## 4. Interruptibility

Anything triggered rapidly or reversible mid-motion (stacking toasts, toggles,
drags, expand and collapse) must use transitions or springs. See
"Interruptibility", "Springs", "Asymmetric timing", and "Gestures and drag" in
STANDARDS.md.

Look for:

- `@keyframes` on toasts, toggles, or rapidly triggered UI;
- gesture handlers animated with fixed-duration keyframes;
- drags that dismiss only on distance, not velocity;
- hard stops at drag edges instead of rising resistance;
- the same timing for press and release on a hold interaction.

## 5. Performance

See "Performance" in STANDARDS.md.

Look for:

- `transition: all`;
- animated layout properties;
- Motion `x`/`y`/`scale` props on busy pages, before `motion` 14.2;
- layout animations (`layout`, `layoutId`) on busy pages;
- `setProperty('--x', ...)` driving child transforms;
- `requestAnimationFrame` loops doing what CSS could;
- transition blur of 20px or more.

## 6. Accessibility

See "Accessibility" in STANDARDS.md.

Look for:

- movement with no `prefers-reduced-motion` handling;
- ungated `:hover` motion;
- reduced-motion handling that removes all feedback instead of only movement.

## 7. Cohesion and tokens

Motion should match the product's personality, and curves and durations should
be shared tokens. See "Cohesion", "Stagger", and "Masking a crossfade" in
STANDARDS.md.

Look for:

- several hand-typed curves or durations that almost match (consolidate them);
- one bouncy component in an otherwise crisp app;
- list or grid entrances with no stagger;
- crossfades that visibly show both states at once.

## 8. Missed opportunities

Places that don't animate but should. This category adds motion instead of
fixing it. Report only a few, each tied to a real problem you saw:

- state changes that jump (content swaps, layout jumps) where a short
  transition would bridge them;
- a panel that appears from a trigger with no motion showing where it came
  from;
- rare, high-emotion moments (first run, success) with no delight at all.

Use `translate` percentages and `clip-path: inset()` reveals for these rather
than hardcoded pixel offsets. For a deeper search, follow the
[find-animation-opportunities guide](../find-animation-opportunities/GUIDE.md).
