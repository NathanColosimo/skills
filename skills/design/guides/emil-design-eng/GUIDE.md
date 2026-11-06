# Design engineering

UI polish, component design, and motion, from Emil Kowalski's approach. Most of
these details go unnoticed one at a time. Together they decide whether an
interface feels right. When a feature works exactly the way someone assumes it
will, they move on without thinking about it. That's the goal.

The full animation values (frequency, easing, duration, springs, performance,
accessibility) are in `../review-animations/STANDARDS.md`. To build an
animation, use the `animate` guide. To critique one, use the
`review-animations` guide. This guide covers the principles and the techniques
those guides don't.

## Review format

When reviewing UI code, report findings as one markdown table, one row per
issue:

| Before | After | Why |
| --- | --- | --- |
| `transition: all 300ms` | `transition: transform 200ms ease-out` | Name the exact properties; `all` animates things you didn't mean to |
| `transform: scale(0)` | `transform: scale(0.95); opacity: 0` | Nothing real appears from nothing |
| `ease-in` on a dropdown | `ease-out` with a custom curve | `ease-in` delays the moment the user is watching |
| No `:active` state on a button | `transform: scale(0.97)` on `:active` | Buttons should respond to a press |
| `transform-origin: center` on a popover | `transform-origin: var(--transform-origin)` | Popovers grow from their trigger (modals stay centered) |

Don't use separate "Before:" and "After:" lines.

## Deciding on motion

Answer these in order. The values are in `../review-animations/STANDARDS.md`.

1. **Should it animate at all?** The more often someone sees it, the less it
   should move. Never animate something seen 100+ times a day, or anything
   triggered from the keyboard. A command palette with no open animation is
   the right design.
2. **What is it for?** Feedback, spatial consistency, showing a state change,
   explaining a feature, or avoiding a jarring jump. "It looks cool" isn't a
   reason for something people see often.
3. **Which easing?** `ease-out` for entering and exiting, `ease-in-out` for
   moving on screen, `ease` for hover and color, `linear` for constant motion.
   Never `ease-in` on UI. Use the custom curves; the built-in ones are too
   weak.
4. **How fast?** Keep UI animation under 300ms. Speed changes how fast the
   whole app feels: a 180ms dropdown feels more responsive than a 400ms one,
   and a faster spinner makes the same load feel shorter.

Use springs for drags, gestures that can be interrupted, and decorative
mouse tracking. A spring keeps its velocity when interrupted, so it reverses
smoothly. Spring mouse-tracking only when it's decoration. On a functional
chart, no motion is better.

## Techniques

### Press feedback

Any pressable element gets a subtle scale on press (0.95 to 0.98). Because
`scale()` also scales the children, the text and icons shrink with it.

```css
.button {
  transition: transform 160ms ease-out;
}

.button:active {
  transform: scale(0.97);
}
```

### Tooltips: skip the delay after the first

Delay the first tooltip so it doesn't open by accident. Once one is open,
hovering the next one opens it instantly with no animation. The toolbar feels
faster without losing the protection of the first delay.

```css
.tooltip {
  transition: transform 125ms ease-out, opacity 125ms ease-out;
  transform-origin: var(--transform-origin);
}

.tooltip[data-starting-style],
.tooltip[data-ending-style] {
  opacity: 0;
  transform: scale(0.97);
}

.tooltip[data-instant] {
  transition-duration: 0ms;
}
```

### Enter without JavaScript

`@starting-style` animates an element in on mount, replacing the
`useEffect(() => setMounted(true), [])` pattern. Fall back to a `data-mounted`
attribute where browser support is missing.

```css
.toast {
  opacity: 1;
  transform: translateY(0);
  transition: opacity 400ms ease, transform 400ms ease;

  @starting-style {
    opacity: 0;
    transform: translateY(100%);
  }
}
```

Use transitions, not keyframes, for anything triggered quickly in a row
(toasts, toggles). A transition retargets from where it is. A keyframe
animation restarts from zero.

### Blur to hide a rough crossfade

If a crossfade still shows two overlapping states after you've tuned the
easing and duration, add a light blur during the change. The blur blends the
two states, so the eye reads one smooth change instead of two objects
swapping. Keep blur under 20px; heavy blur is slow, especially in Safari.

```css
.button-content {
  transition: filter 200ms ease, opacity 200ms ease;
}

.button-content.transitioning {
  filter: blur(2px);
  opacity: 0.7;
}
```

### clip-path

`clip-path: inset(top right bottom left)` cuts into the element from each
side, and it animates cheaply.

- **Hold to delete:** a colored overlay starts at `inset(0 100% 0 0)`. On
  `:active` it fills to `inset(0 0 0 0)` over 2s, linear. On release it snaps
  back in 200ms, ease-out. Slow while the user decides, fast when the system
  responds.
- **Tabs with clean color changes:** duplicate the tab list and style the copy
  as active. Clip the copy so only the active tab shows, and animate the clip
  when the tab changes. This looks better than transitioning each tab's color.
- **Reveal on scroll:** start at `inset(0 0 100% 0)` and animate to
  `inset(0 0 0 0)` when the element enters the viewport. Use
  `IntersectionObserver` or Motion's `useInView` with
  `{ once: true, margin: "-100px" }`.
- **Comparison slider:** stack two images and clip the top one with
  `inset(0 50% 0 0)`. Change the right inset as the user drags. No extra
  elements needed.

```css
.overlay {
  clip-path: inset(0 100% 0 0);
  transition: clip-path 200ms ease-out;
}

.button:active .overlay {
  clip-path: inset(0 0 0 0);
  transition: clip-path 2s linear;
}
```

### Drag and swipe

- **Dismiss on a flick.** Don't require dragging past a distance. Compute
  velocity, and dismiss when it's above about 0.11 even if the distance is
  short.
- **Resist past the edge.** Dragging past a boundary should move the element
  less and less, instead of stopping dead.
- **Capture the pointer** once the drag starts, so it continues when the
  pointer leaves the element.
- **Ignore extra fingers** after the drag starts, or switching fingers makes
  the element jump.

```js
const timeTaken = Date.now() - dragStartTime.current;
const velocity = Math.abs(swipeAmount) / timeTaken;

if (Math.abs(swipeAmount) >= SWIPE_THRESHOLD || velocity > 0.11) {
  dismiss();
}
```

### 3D depth

`rotateX()`, `rotateY()`, and `transform-style: preserve-3d` give real depth
in CSS: orbits, coin flips, cards with perspective. No JavaScript needed.

```css
.wrapper {
  transform-style: preserve-3d;
}

@keyframes orbit {
  from {
    transform: translate(-50%, -50%) rotateY(0deg) translateZ(72px) rotateY(360deg);
  }
  to {
    transform: translate(-50%, -50%) rotateY(360deg) translateZ(72px) rotateY(0deg);
  }
}
```

## Building components people love

These come from building Sonner, the toast library, and apply to any
component.

1. **Make it easy to adopt.** No required hooks, context, or setup. Sonner is
   `<Toaster />` once and `toast()` anywhere.
2. **Defaults matter more than options.** Most people never customize. The
   default easing, timing, and look should already be right.
3. **Handle edge cases where nobody sees them.** Pause toast timers while the
   tab is hidden. Fill the gaps between stacked toasts with
   pseudo-elements so the stack stays hovered. Capture the pointer during a drag.
4. **Match motion to the personality.** A playful component can bounce. A
   dashboard should be crisp and fast. Sonner is slightly slower than usual
   and uses `ease` instead of `ease-out`, to feel calmer.
5. **Make the docs interactive.** Let people try the component before they
   install it, with code they can copy.

Some things have no formula. When list items enter and exit, getting opacity
and height to work together takes trial and error.

## Checking your work

- Slow animations down 2-5x, or step through them frame by frame in the
  DevTools Animations panel. Check that colors blend cleanly, the easing
  doesn't stop abruptly, the transform origin is right, and properties that
  should move together stay in sync.
- Test gestures on a real phone. Open the dev server by IP and use Safari's
  remote DevTools.
- Look again the next day. You'll see problems you missed while building it.

## Review checklist

| Issue | Fix |
| --- | --- |
| `transition: all` | Name the properties: `transition: transform 200ms ease-out` |
| Entry from `scale(0)` | Start from `scale(0.95)` with `opacity: 0` |
| `ease-in` on UI | `ease-out` or a custom curve |
| `transform-origin: center` on a popover | The trigger's position, or Base UI's `var(--transform-origin)`. Modals stay centered |
| Animation on a keyboard action | Remove it |
| UI duration over 300ms | 150-250ms |
| Hover animation without a media query | Wrap in `@media (hover: hover) and (pointer: fine)` |
| Keyframes on something triggered quickly | A CSS transition |
| Motion `x`/`y` props under load, before Motion 14.2 | Upgrade to 14.2+, or use `transform: "translateX()"` |
| Enter and exit at the same speed | Make the exit faster (hold to delete: 2s in, 200ms out) |
| A group that appears all at once | Stagger 30-80ms between items |
| Animating `width`, `height`, `padding`, or `margin` | Animate `transform` and `opacity` instead |
| A CSS variable on a parent driving a child's transform | Set `transform` on the child directly |
| No reduced-motion handling | Keep fades, drop movement. Reduced means gentler, not none |
