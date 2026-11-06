# Animation standards

The values and rules behind every animation guide. Cite them exactly; don't
approximate. Based on Emil Kowalski's design engineering work.

## Should it animate?

| How often the user sees it | Decision |
| --- | --- |
| 100+ times a day (keyboard shortcuts, command palette) | No animation. |
| Tens of times a day (hover effects, list navigation) | Remove it, or make it fast and subtle. |
| Occasionally (modals, drawers, toasts) | Standard animation. |
| Rarely or once (onboarding, success, celebration) | Room for delight. |

Never animate keyboard-initiated actions. They repeat hundreds of times a day,
and animation makes them feel slow. Raycast has no open/close animation, which
is right for something used that often.

Every animation needs a purpose:

- **Feedback:** confirms the interface heard the user.
- **Spatial consistency:** shows where something came from or went.
- **State indication:** makes a state change readable.
- **Preventing a jarring change:** bridges content that would otherwise jump,
  appear, or vanish.
- **Explanation:** shows how a feature works (marketing and onboarding).
- **Delight:** only for rare moments.

"It looks cool" is not a purpose.

## Easing

- Entering or exiting: `ease-out`.
- Moving or morphing on screen: `ease-in-out`.
- Hover or color change: `ease`.
- Constant motion (marquee, progress): `linear`.
- Anything else: `ease-out`.

Never use `ease-in` on UI. It starts slow, delaying the moment the user is
watching. `ease-out` at 200ms feels faster than `ease-in` at 200ms.

The built-in CSS curves are too weak. Use strong custom curves, stored as
tokens:

```css
--ease-out: cubic-bezier(0.23, 1, 0.32, 1);     /* UI entrances and exits */
--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1); /* movement on screen */
--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);  /* iOS-like drawer */
```

Find other curves at [easing.dev](https://easing.dev/) or
[easings.co](https://easings.co/) instead of making them up.

## Duration

| Element | Duration |
| --- | --- |
| Button press feedback | 100-160ms |
| Tooltips, small popovers | 125-200ms |
| Dropdowns, selects | 150-250ms |
| Modals, drawers | 200-500ms |
| Marketing, explanatory | Can be longer |

Keep UI animations under 300ms. A 180ms dropdown feels more responsive than a
400ms one. A faster spinner makes the same load feel shorter. In a toolbar,
show tooltips after the first one instantly, with no delay or animation.

## Physical correctness

- **Never start from `scale(0)`.** Nothing appears from nothing. Start from
  `scale(0.9)` to `scale(0.97)` with `opacity: 0`.
- **Scale popovers from their trigger,** not the center:
  ```css
  .popover { transform-origin: var(--transform-origin); } /* Base UI */
  ```
  Modals are the exception: they sit in the center of the viewport, so
  `transform-origin: center` is correct.
- **Press feedback:** `transform: scale(0.97)` on `:active`, with
  `transition: transform 160ms ease-out`. Keep it between 0.95 and 0.98. It
  applies to anything pressable.

## Springs

Springs simulate physics, so they have no fixed duration. Use them for drag
with momentum, elements that should feel alive, gestures the user might
reverse, and decorative mouse tracking.

```js
// Apple-style, easier to reason about (recommended)
{ type: "spring", duration: 0.5, bounce: 0.2 }

// Physics-style, more control
{ type: "spring", mass: 1, stiffness: 100, damping: 10 }
```

Keep bounce between 0.1 and 0.3. Avoid bounce in most UI; save it for
drag-to-dismiss and playful moments. A spring keeps its velocity when
interrupted, while keyframes restart from zero.

For decorative mouse tracking, smooth the value with `useSpring` instead of
tying it directly to the pointer, which feels mechanical.

## Interruptibility

A CSS transition can be interrupted and retargets from where it is. A keyframe
animation restarts from zero. Use transitions for anything triggered rapidly,
like stacking toasts or toggles.

```css
/* Interruptible: use for dynamic UI */
.toast { transition: transform 400ms ease; }

/* Restarts from zero: avoid for dynamic UI */
@keyframes slideIn { from { transform: translateY(100%); } to { transform: translateY(0); } }
```

Use `@starting-style` to animate entry without JavaScript:

```css
.toast {
  opacity: 1; transform: translateY(0);
  transition: opacity 400ms ease, transform 400ms ease;
  @starting-style { opacity: 0; transform: translateY(100%); }
}
```

Older browsers: set a `data-mounted` attribute after mount and transition on
it.

## Asymmetric timing

Go slow where the user is deciding and fast where the system responds:

```css
.overlay { transition: clip-path 200ms ease-out; }           /* release: fast */
.button:active .overlay { transition: clip-path 2s linear; } /* hold: slow */
```

## Performance

- **Animate only `transform` and `opacity`.** They skip layout and paint.
  Animating `width`, `height`, `margin`, `padding`, `top`, or `left` triggers
  layout, paint, and composite on every frame.
- **Never `transition: all`.** It animates properties you didn't intend.
- **Don't drive a child's transform through a CSS variable on its parent.**
  It recalculates styles for every child. Set `transform` on the element:
  ```js
  element.style.setProperty('--swipe-amount', `${d}px`); // bad: restyles all children
  element.style.transform = `translateY(${d}px)`;        // good: only this element
  ```
- **Motion's `x`, `y`, and `scale` props are hardware-accelerated from
  `motion` 14.2.** Before 14.2 they run on the main thread and drop frames
  under load; upgrade or use the full transform string. Layout animations
  (`layout`, `layoutId`) run on the main thread in every version.
  ```jsx
  <motion.div animate={{ x: 100 }} />                         // 14.2+: accelerated
  <motion.div animate={{ transform: "translateX(100px)" }} /> // accelerated in every version
  ```
- **CSS beats JavaScript under load.** CSS animations run off the main thread;
  `requestAnimationFrame` animations stutter while the page is busy. Use CSS
  for fixed motion and JavaScript for dynamic or interruptible motion.
- **The Web Animations API** gives JavaScript control with CSS performance:
  ```js
  element.animate([{ clipPath: 'inset(0 0 100% 0)' }, { clipPath: 'inset(0 0 0 0)' }],
    { duration: 1000, fill: 'forwards', easing: 'cubic-bezier(0.77, 0, 0.175, 1)' });
  ```

## Transforms and clip-path

- **`translate` percentages** are relative to the element's own size.
  `translateY(100%)` moves it by its own height, whatever that is. Prefer it to
  hardcoded pixels for toasts and drawers.
- **`scale()` scales the children too,** including text and icons. That's what
  you want for press feedback.
- **3D:** `rotateX`/`rotateY` with `transform-style: preserve-3d` gives depth,
  flips, and orbits without JavaScript.
- **`clip-path: inset(top right bottom left)`** cuts in from each side. Use it
  for reveals (`inset(0 0 100% 0)` to `inset(0 0 0 0)`), hold-to-delete
  overlays, tab color transitions (duplicate the tabs and clip the active
  copy), and comparison sliders.

## Gestures and drag

- **Dismiss on velocity,** not only distance:
  `Math.abs(distance) / elapsedMs` above about `0.11`. A flick should be enough.
- **Add resistance at the edges.** Past a natural boundary, the element moves
  less the further it's dragged, instead of stopping at an invisible wall.
- **Capture the pointer** once a drag starts, so it continues outside the
  element.
- **Ignore extra touches** after a drag begins (`if (isDragging) return`), so
  a second finger doesn't make it jump.

## Masking a crossfade

If a crossfade still shows two overlapping states after tuning the easing and
duration, add `filter: blur(2px)` during the transition so the two read as one
change. Keep blur under 20px; heavy blur is expensive, especially in Safari.

## Stagger

Stagger group entrances by 30-80ms per item. Longer feels slow. Stagger is
decoration, so never block interaction while it plays.

```css
.item { opacity: 0; transform: translateY(8px); animation: fadeIn 300ms ease-out forwards; }
.item:nth-child(2) { animation-delay: 50ms; }
.item:nth-child(3) { animation-delay: 100ms; }
@keyframes fadeIn { to { opacity: 1; transform: translateY(0); } }
```

## Accessibility

```css
@media (prefers-reduced-motion: reduce) {
  .element { animation: fade 0.2s ease; } /* keep opacity and color, drop movement */
}
@media (hover: hover) and (pointer: fine) {
  .element:hover { transform: scale(1.05); } /* touch fires a hover on tap */
}
```

```jsx
const reduce = useReducedMotion();
const closedX = reduce ? 0 : '-100%';
```

Reduced motion means fewer and gentler animations, not none. Keep transitions
that help understanding; remove movement and position changes.

## Checking how it feels

When you can't judge motion from the code, recommend one of these instead of
guessing:

- **Slow motion:** raise the duration 2-5x, or use the DevTools Animations
  panel. Check that colors crossfade cleanly, the easing doesn't stop
  abruptly, the origin is right, and coordinated properties stay in sync.
- **Frame by frame:** the Chrome DevTools Animations panel shows timing drift
  between properties.
- **A real device** for gestures like drawers and swipes: open the dev server
  by IP on a phone and use Safari remote devtools.
- **Fresh eyes the next day.**

## Cohesion

Match motion to the component and the product. A playful app can bounce more;
a dashboard stays crisp and fast. Sonner feels right partly because its
easing, duration, and design agree: slightly slower, with `ease` instead of
`ease-out`, to feel elegant. Animating opacity and height in a list that gains
and loses items takes trial and error; adjust until it feels right.
