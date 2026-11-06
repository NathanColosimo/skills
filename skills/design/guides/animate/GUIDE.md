# Building animations

Use this to turn a request for motion into an implementation on the web. For
React Native, use the `animate-expo` guide. To critique existing motion, use
the `review-animations` guide. To audit a whole codebase, use the
`improve-animations` guide.

Two mistakes matter most, and the first is worse:

1. **Animating something that shouldn't animate.** The first two steps below
   sometimes end with no code at all. That's a correct result.
2. **Using the wrong ingredients:** `ease-in` on an entrance, `scale(0)`,
   keyframes on a toast, a duration that makes a dropdown feel slow.

Make the call yourself. Don't offer a menu of motion options; state your
reasoning in one line and write the code.

## Rules

- **Go through the steps in order.** Steps 1 and 2 decide whether anything
  animates. Don't pick a curve before that.
- **Use the values in this guide.** Every curve, duration, and spring config
  comes from the tables below. Never make up a curve because it looks
  familiar.
- **Use the codebase's existing tokens.** If `--ease-out` or a duration scale
  already exists, use it. Don't add a second system.
- **Ship reduced motion and hover gating with the animation,** not later.
- **Use the cheapest tool that works.** Don't install a motion library for a
  fade.

## 1. Should it animate at all?

| How often the user sees it | Decision |
| --- | --- |
| 100+ times a day (keyboard shortcuts, command palette toggle) | **No animation.** Stop here. |
| Tens of times a day (hover effects, list navigation) | Barely noticeable motion only, or none |
| Occasionally (modals, drawers, toasts) | Standard animation |
| Rarely or once (onboarding, success, celebration) | Room for delight |

Anything triggered from the keyboard doesn't animate. Raycast has no
open/close animation, which is right for something opened hundreds of times a
day.

If the request fails this step, say so and don't write the animation. Offer
the non-motion alternative, like an instant state change or a static
affordance.

## 2. What is it for?

Name the purpose before going on:

- **Feedback:** confirms the interface heard the user.
- **Spatial consistency:** shows where something came from or went.
- **State indication:** makes a state change readable.
- **Preventing a jarring change:** bridges content that would otherwise jump.
- **Explanation:** shows how something works (marketing and onboarding only).
- **Delight:** only for things the user sees rarely.

If you can't name one, don't build it. "It looks cool" is not a purpose.

Data the user is reading or acting on should not move for style. A mouse-
tracking effect belongs on a marketing page, not on a graph in a banking app.

## 3. Pick the tool

Go down the table and stop at the first row that fits.

| Need | Tool |
| --- | --- |
| Hover, press, color, or a state toggled by a class or attribute | **CSS transition** |
| An entry animation on mount, with no JS state | **CSS `@starting-style`** |
| Fixed motion that must stay smooth while the page is busy loading | **CSS animation** (runs off the main thread) |
| Control from JS with CSS performance, no library | **WAAPI** (`element.animate()`) |
| Springs, layout animations, exit animations, gesture-driven values | **Motion** (`motion.dev`) |

CSS animations stay smooth under load because they run off the main thread.
Animations driven by `requestAnimationFrame` drop frames while the browser is
loading, running scripts, or painting. Use CSS for fixed motion and JS for
dynamic, interruptible motion.

If the task is really a component (a toast, drawer, command menu, dropdown),
use a component library instead of building it by hand. Hand-built versions
end up as a `<div>` dropdown with no focus management.

## 4. Pick the properties

- **Animate only `transform` and `opacity`.** They skip layout and paint and
  run on the GPU. `width`, `height`, `margin`, `padding`, `top`, and `left`
  trigger layout, paint, and compositing on every frame. `clip-path` is also
  fine (see [RECIPES.md](RECIPES.md)). `height` is acceptable only for
  accordions, where nothing else works.
- **Never start from `scale(0)`.** Start from `scale(0.9)` to `scale(0.97)`
  with `opacity: 0`. Nothing real appears out of nothing.
- **Set `transform-origin` at the trigger** for popovers, dropdowns, menus,
  and tooltips (`var(--transform-origin)` in Base UI). Modals are the
  exception: they aren't anchored to a trigger, so they stay centered.
- **Use percentages in `translate()`.** They're relative to the element's own
  size, so `translateY(100%)` moves it by its own height whatever the
  content. Prefer them to fixed pixels.
- **In Motion 14.2 and later,** independent transforms like `x`, `y`,
  `scale`, and `rotate` are hardware accelerated. In older versions, use a
  full `transform` string:

```jsx
<motion.div animate={{ x: 100 }} />                          // accelerated in 14.2+
<motion.div animate={{ transform: "translateX(100px)" }} />  // accelerated in every version
```

- **Don't drive a child's transform from a CSS variable on the parent.** It
  recalculates styles for every child. Set `transform` on the element itself.

## 5. Easing and duration, or a spring

**Easing:**

| Situation | Easing |
| --- | --- |
| Entering or exiting | `ease-out` |
| Moving or morphing on screen | `ease-in-out` |
| Hover or color change | `ease` |
| Constant motion (marquee, progress) | `linear` |
| Anything else | `ease-out` |

**Never use `ease-in` on UI.** It starts slow, delaying the moment the user
is watching. `ease-out` at 200ms feels faster than `ease-in` at 200ms.

The built-in CSS curves are too weak. Use these:

```css
--ease-out: cubic-bezier(0.23, 1, 0.32, 1);        /* strong ease-out for UI */
--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1);    /* strong ease-in-out for on-screen movement */
--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);     /* iOS-like drawer curve (Ionic) */
```

For a curve that isn't here, take one from [easing.dev](https://easing.dev/)
or [easings.co](https://easings.co/). Don't hand-roll one.

**Duration:**

| Element | Duration |
| --- | --- |
| Button press feedback | 100–160ms |
| Tooltips, small popovers | 125–200ms |
| Dropdowns, selects | 150–250ms |
| Modals, drawers | 200–500ms |
| Marketing and explanatory | Can be longer |

Keep UI animations under 300ms. A 180ms dropdown feels more responsive than a
400ms one.

**Use a spring instead** for a drag with momentum, an element that should feel
alive, a gesture the user can interrupt or reverse, or decorative mouse
tracking:

```js
{ type: "spring", duration: 0.5, bounce: 0.2 }            // Apple-style, easier to reason about
{ type: "spring", mass: 1, stiffness: 100, damping: 10 }  // physics-style, more control
```

Keep bounce between 0.1 and 0.3, and leave it out of most UI. Save it for
drag-to-dismiss and playful interactions.

## 6. Interruption and exit

- **Use transitions, not keyframes, for anything triggered quickly:** toasts,
  toggles, anything a user can fire twice in a second. Transitions continue
  from the current value; keyframes restart from zero.
- **Use springs for gestures.** They carry velocity through an interruption.
- **Exit the way it entered.** A toast that slides in from the bottom leaves
  through the bottom. Matching paths make swipe-to-dismiss feel obvious.
- **Make timing uneven where the user is deciding.** Slow during the
  deliberate part (holding to confirm: 2s linear), fast for the system's
  response (release: 200ms ease-out).

## 7. Reduced motion and pointer gating

Ship these with every animation:

```css
@media (prefers-reduced-motion: reduce) {
  .element { animation: fade 0.2s ease; } /* keep opacity and color, drop movement */
}

@media (hover: hover) and (pointer: fine) {
  .element:hover { transform: scale(1.05); } /* touch screens fire false hovers on tap */
}
```

```jsx
const reduce = useReducedMotion();
const closedX = reduce ? 0 : '-100%';
```

Reduced motion means fewer and gentler animations, not none. Keep transitions
that help the user understand a change; remove movement and position changes.

## Recipes

[RECIPES.md](RECIPES.md) has ready implementations for: button press,
dropdown, tooltip, modal, drawer, toast, accordion, staggered entrance,
hold-to-confirm, tab indicator, scroll reveal, and drag-to-dismiss. When the
request matches one, start from the recipe.

## Never ship

Check these before you finish. The `review-animations` guide blocks every one.

| Never | Instead |
| --- | --- |
| `transition: all` | Name the exact properties |
| A `scale(0)` entrance | `scale(0.95)` with `opacity: 0` |
| `ease-in` on a UI element | `ease-out` or a strong custom curve |
| The built-in `ease-out` on a deliberate animation | `cubic-bezier(0.23, 1, 0.32, 1)` |
| Animation on a keyboard shortcut or a 100+/day action | No animation |
| A UI duration over 300ms with no reason | 150–250ms |
| `transform-origin: center` on a popover anchored to a trigger | `var(--transform-origin)` (modals excepted) |
| Keyframes on toasts, toggles, or anything triggered quickly | CSS transitions |
| Animating `width`, `height`, `margin`, `padding`, `top`, or `left` | `transform` and `opacity` |
| Motion `x`/`y`/`scale` props under load, before version 14.2 | Upgrade to 14.2+, or use a full `transform` string |
| `:hover` motion with no pointer gating | `@media (hover: hover) and (pointer: fine)` |
| No `prefers-reduced-motion` handling | A gentler variant, not none |
| Everything entering at once | A 30–80ms stagger |

## What to report

Write the code. Then add a few lines:

- **The decision:** how often the user sees it and the purpose you named. If
  you rejected part of the request, say which part and why.
- **The ingredients:** tool, properties, curve, and duration or spring config,
  one line each.
- **What to check by eye:** when the result depends on feel you can't judge
  from code (a crossfade, a spring's bounce, opacity against height in an
  entering list), say so. Play it at 2–5× duration or in the DevTools
  animation inspector, step through it frame by frame, test gestures on a real
  device, and look again the next day.

Keep it short. The code is the deliverable.
