# Animation recipes

Starting points for the most common cases. Start from the recipe and adapt it.

The curves are the `--ease-out`, `--ease-in-out`, and `--ease-drawer` tokens
defined in [GUIDE.md](GUIDE.md).


## Button press

Any pressable element. It shows the interface heard the press.

```css
.button {
  transition: transform 160ms var(--ease-out);
}

.button:active {
  transform: scale(0.97);
}
```

`scale()` scales the children too. The label and icons shrink with it, which makes it read as a physical press.

No hover gating is needed: `:active` is a real press on touch screens. Gate any `:hover` styles separately.


## Dropdown, popover, menu, select

It scales out of its trigger.

```css
.popover {
  transform-origin: var(--transform-origin); /* Base UI supplies this */
  transition:
    opacity 200ms var(--ease-out),
    transform 200ms var(--ease-out);
}

.popover[data-starting-style],
.popover[data-ending-style] {
  opacity: 0;
  transform: scale(0.95);
}
```

The `transform-origin` matters most: the panel should look like it came out of the thing you clicked.


## Tooltip

Like a popover, but faster, and with one extra rule.

```css
.tooltip {
  transform-origin: var(--transform-origin);
  transition:
    transform 125ms var(--ease-out),
    opacity 125ms var(--ease-out);
}

.tooltip[data-starting-style],
.tooltip[data-ending-style] {
  opacity: 0;
  transform: scale(0.97);
}

/* Once one tooltip is open, its neighbors open instantly */
.tooltip[data-instant] {
  transition-duration: 0ms;
}
```

Keep the initial delay so tooltips don't open by accident. Once one is open, skip both the delay and the animation for the next one, so moving along a toolbar feels fast.


## Modal

The one popover that stays centered.

```css
.modal {
  transform-origin: center; /* exempt — not anchored to a trigger */
  transition:
    opacity 250ms var(--ease-out),
    transform 250ms var(--ease-out);
}

.modal[data-starting-style],
.modal[data-ending-style] {
  opacity: 0;
  transform: scale(0.96);
}

.backdrop {
  transition: opacity 250ms var(--ease-out);
}
```

Animate the backdrop's opacity with it so they read as one surface.


## Drawer / sheet

```css
.drawer {
  transform: translateY(0);
  transition: transform 500ms var(--ease-drawer);
}

.drawer[data-closed] {
  transform: translateY(100%);
}
```

This is how Vaul hides a drawer before animating it in. For dragging, see **Drag to dismiss** below.


## Toast

```css
.toast {
  opacity: 1;
  transform: translateY(0);
  transition:
    opacity 400ms ease,
    transform 400ms ease;

  @starting-style {
    opacity: 0;
    transform: translateY(100%);
  }
}
```

- It uses `ease` instead of `ease-out`, and runs a little slower than typical UI. Sonner's toasts feel calm partly because their timing suits the component rather than the general UI budget.
- Where `@starting-style` isn't supported, fall back to a mount flag:

```jsx
useEffect(() => { setMounted(true); }, []);
// <div data-mounted={mounted}>
```

When toasts stack and the list reflows, the opacity change has to work against the height change. There's no formula for that pair. Adjust until it feels right, then check again the next day.


## Accordion / collapse

```css
.content {
  overflow: hidden;
  transition:
    height 200ms var(--ease-out),
    opacity 200ms var(--ease-out);
}
```

Keep it short. This is one of the few animations that runs layout on every frame, so a long one is expensive as well as slow. Measure the content height in JS, or use a headless component that provides it, instead of animating to `auto`.


## Stagger a group entrance

For a list or grid the user sees occasionally, not one they scroll past all day.

```css
.item {
  opacity: 0;
  transform: translateY(8px);
  animation: fadeIn 300ms var(--ease-out) forwards;
}

.item:nth-child(2) { animation-delay: 50ms; }
.item:nth-child(3) { animation-delay: 100ms; }
.item:nth-child(4) { animation-delay: 150ms; }

@keyframes fadeIn {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

Stagger is decoration. It must never block interaction while it plays.


## Hold to confirm

For destructive actions where a plain click is too easy to hit by accident.

```css
.overlay {
  clip-path: inset(0 100% 0 0);
  transition: clip-path 200ms var(--ease-out); /* release: snappy */
}

.button:active .overlay {
  clip-path: inset(0 0 0 0);
  transition: clip-path 2s linear;             /* press: slow and deliberate */
}

.button:active {
  transform: scale(0.97);
}
```

`linear` is right here: the fill shows progress, and progress shouldn't ease.


## Tab indicator with a color transition

Timing separate color transitions across a tab list never quite lines up. Clip instead.

Duplicate the tab list and style the copy as the active state, with its own background and text color. Clip the copy so only the active tab shows, and animate the clip when the tab changes:

```css
.tabs-active-copy {
  clip-path: inset(0 60% 0 20%); /* driven by the active tab's position */
  transition: clip-path 250ms var(--ease-in-out);
}
```

The text and background change in sync, because one element is being revealed instead of two colors being blended.


## Scroll reveal

Marketing pages only. Don't do this to UI people use every day.

```css
.reveal {
  clip-path: inset(0 0 100% 0);
  transition: clip-path 600ms var(--ease-in-out);
}

.reveal[data-visible] {
  clip-path: inset(0 0 0 0);
}
```

Trigger it with `IntersectionObserver`, or Motion's `useInView` with `{ once: true, margin: "-100px" }`. Fire it once. Re-animating every time the element scrolls past gets in the reader's way.


## Drag to dismiss

Use springs, not durations, because the user can reverse mid-motion.

```js
// Dismiss on a flick, not just on distance
const timeTaken = Date.now() - dragStartTime.current;
const velocity = Math.abs(swipeAmount) / timeTaken;

if (Math.abs(swipeAmount) >= SWIPE_THRESHOLD || velocity > 0.11) {
  dismiss();
}
```

```js
// Set transform on the dragged element directly.
// Driving it through a CSS variable on the parent recalcs styles for every child.
element.style.transform = `translateY(${distance}px)`;
```

Get these four details right:

- **Capture the pointer** once the drag starts, so it continues when the pointer leaves the element.
- **Ignore extra touches:** `if (isDragging) return` on new touch points, or switching fingers mid-drag makes the element jump.
- **Dampen past the edge:** dragging beyond a natural boundary moves the element less the further it goes.
- **Resist instead of stopping:** allow the over-drag with rising resistance rather than blocking it.

Settle with a spring, so an interrupted drag keeps its velocity:

```js
{ type: "spring", duration: 0.5, bounce: 0.2 }
```


## Masking a crossfade that won't settle

When two states visibly overlap during a transition and no easing or duration fixes it, blur them:

```css
.content {
  transition:
    filter 200ms ease,
    opacity 200ms ease;
}

.content.transitioning {
  filter: blur(2px);
  opacity: 0.7;
}
```

Without blur, the eye sees two objects swapping. With it, they read as one thing changing. Keep the blur under 20px; heavy blur is expensive, especially in Safari.


## Programmatic, without a library

When the motion needs JS control but not a library, WAAPI performs like CSS:

```js
element.animate(
  [{ clipPath: 'inset(0 0 100% 0)' }, { clipPath: 'inset(0 0 0 0)' }],
  { duration: 1000, fill: 'forwards', easing: 'cubic-bezier(0.77, 0, 0.175, 1)' }
);
```

It's hardware accelerated, interruptible, and adds nothing to the bundle.
