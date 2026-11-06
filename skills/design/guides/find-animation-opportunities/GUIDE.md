# Finding animation opportunities

Search an interface for places that should animate but don't, and propose an
exact recipe for each. This guide proposes; it doesn't implement, and it
doesn't review existing motion. For that, use the
[review-animations guide](../review-animations/GUIDE.md) or the
[improve-animations guide](../improve-animations/GUIDE.md).

The starting point is Emil Kowalski's
["You Don't Need Animations"](https://emilkowal.ski/ui/you-dont-need-animations):
often the best animation is none. Expect to reject most candidates. A short
list of strong suggestions beats a long wishlist.

## Rules

1. **Don't change source code.** To build a suggestion, follow the
   improve-animations guide to write a plan for it, or hand the recipe to any
   agent.
2. **Every suggestion passes the whole gate below.**
3. **Suggest at most 5-7 for a whole app,** fewer for a single view, ordered by
   impact.

## The gate

Every candidate must pass all four questions, in order. Record each answer for
the report. The tables are in
[../review-animations/STANDARDS.md](../review-animations/STANDARDS.md).

1. **How often is it seen?** Use "Should it animate?" in STANDARDS.md.
   Keyboard-initiated actions are rejected outright. Things seen tens of times
   a day get, at most, fast and subtle motion.
2. **What is the purpose?** Name one from the purpose list in STANDARDS.md.
   Delight is allowed only for rare moments. If you can't name a purpose,
   reject it.
3. **Can it stay within budget?** It must work within the durations in
   STANDARDS.md (UI under 300ms). If it only works slow and showy, reject it.
4. **Does motion help here?** Decoration hurts functional, information-dense
   UI. A mouse-tracking effect is fine on a marketing page; on a chart in a
   banking app, no animation is better. Don't move data the user is trying to
   read or act on.

## Where to look

**Missing feedback**

- Pressable elements with no `:active` state: `transform: scale(0.97)` with
  `transition: transform 160ms ease-out` (0.95-0.98).
- Destructive actions confirmed with a plain click, where holding to confirm
  would prevent slips: a `clip-path: inset(0 100% 0 0)` overlay, 2s linear on
  press, 200ms ease-out back on release.

**State that jumps**

- Content that swaps, appears, or vanishes instantly (conditional renders,
  route content, expanding sections): enter from `scale(0.95)` to `scale(0.97)`
  with `opacity: 0`, `ease-out`, never `scale(0)`. Use `@starting-style` for
  entry without JavaScript.
- Accordions that snap open: transition height and opacity.
- List items added or removed with no transition, in a list that isn't used
  constantly: enter and exit transitions, using CSS transitions rather than
  keyframes so rapid changes retarget smoothly.

**No sense of where things come from**

- Panels, popovers, and menus that appear with no link to their trigger: scale
  in with `transform-origin` at the trigger (Base UI:
  `var(--transform-origin)`). Modals stay centered.
- Toasts and sheets that leave a different way than they came: use the same
  path both ways, with `translateY(100%)` rather than hardcoded pixels.

**Group entrances**

- A grid or list that pops in all at once, on a page seen occasionally: stagger
  30-80ms per item. It's decoration and must never block interaction.

**Gestures**

- Draggable or swipeable elements that snap with no physics: springs
  (`{ type: "spring", duration: 0.5, bounce: 0.2 }`, bounce 0.1-0.3),
  dismissal on velocity (`Math.abs(distance) / elapsedMs > 0.11`, about), and
  resistance at the edges instead of hard stops.

**Rare moments**

- First run, empty states, success, and celebration shown flat. These are the
  only places for bounce, generous stagger, or a longer beat.

Useful searches: conditional renders with no transition (`{isOpen &&`,
`display: none` toggles), `onClick` handlers on elements with no `:active` or
transition styles, `details` and accordion markup, drag handlers, `.map(`
renders of lists that gain items, and empty-state and success components.

## Steps

1. **Recon.** Find the stack, the motion libraries, and the existing easing and
   duration tokens. Suggestions extend these instead of adding new ones. Judge
   the product's personality: a crisp dashboard gets fewer, subtler
   suggestions than a playful app. Note roughly how often users see each
   surface.
2. **Search** every category above. Each one either produces candidates with
   `file:line` evidence or is cleared.
3. **Gate** every candidate through all four questions.
4. **Report** in the format below. If nothing passes, say so. That's a good
   result.

## Output

### 1. Opportunities

One row per suggestion that passed, ordered by impact:

| # | Location | Today | Purpose | Frequency | Suggested motion |
| --- | --- | --- | --- | --- | --- |
| 1 | `Toast.tsx:41` | New toasts appear instantly | Preventing a jarring change | Occasional | Enter with `@starting-style`: `opacity: 0; translateY(100%)` to settled, `transition: 400ms ease`, exit the same edge |
| 2 | `Button.tsx:18` | No press feedback | Feedback | Tens a day | `:active { transform: scale(0.97) }`, `transition: transform 160ms ease-out`, subtle enough for its frequency |

Give exact values in every "Suggested motion" cell: the curve, the duration,
the properties, from STANDARDS.md. Animate only `transform` and `opacity`.
Include reduced-motion handling (gentler, not none), and gate hover motion
behind `@media (hover: hover) and (pointer: fine)`.

### 2. Rejected candidates

List 2-5 places you considered and rejected, each with the gate question that
ruled it out:

- `CommandMenu.tsx:12`, command palette open and close. Rejected: keyboard
  action, 100+ times a day.
- `Chart.tsx:88`, animated line drawing on an analytics chart. Rejected: data
  the user is reading.

### 3. Verdict

One short paragraph: how much motion this interface needs, whether it's
already close, and which suggestion matters most. To build any row, write a
plan for it with the improve-animations guide.

When you can't judge the feel from code alone, say so instead of guessing.
