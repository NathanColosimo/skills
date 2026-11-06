# Building animations in Expo

Use this to build motion in React Native and Expo with Reanimated, Gesture
Handler, Expo Router, and expo-haptics. For the web, use the `animate` guide.

Mobile changes three things, and everything below follows from them:

1. **There is no hover.** Every affordance the web puts in hover has to move to
   press, position, or nowhere.
2. **There are two runtimes.** React renders and your app logic runs on the
   React Native runtime. Worklets run every frame on the UI runtime. An
   animation that touches the React Native runtime stutters as soon as the app
   does anything else. Keep motion on the UI runtime.
3. **The user's finger is on the element.** Gestures are the main input, so
   interrupting a gesture and handing off its velocity are the baseline, not
   polish.

Two mistakes matter most, and the first is worse:

1. **Animating something that shouldn't animate.** The first two steps
   sometimes end with no code at all.
2. **Animating on the wrong thread:** a `setState` per frame, a
   `PanResponder`, an animated `height`. It looks fine in dev on a new phone
   and drops to 20fps on a three-year-old Android.

Make the call yourself. Don't offer a menu of options; state your reasoning in
one line and write the code.

## Rules

- **Go through the steps in order.** Steps 1 and 2 decide whether anything
  animates.
- **Use Reanimated, not core `Animated`.** Core `Animated` can't follow a
  gesture without crossing to the JS thread, and `useNativeDriver` only allows
  transform and opacity. Reanimated worklets run on the UI thread and keep
  running while JS is busy.
- **Use the values in this guide.** Curves and spring configs come from the
  tables below.
- **Ship reduced motion with the animation,** not later.
- **Judge feel on a release build, on the slowest device you support.**
  Nothing else counts as checked.

## 1. Should it animate at all?

| How often the user sees it | Decision |
| --- | --- |
| 100+ times a day: tab switches, keyboard open and close, scrolling, settings toggles | **No animation.** Platform default or nothing. Stop here. |
| Tens of times a day: press feedback, list navigation, row selection | Barely noticeable only: under 150ms, or nothing |
| Occasionally: sheets, modals, toasts, onboarding steps | Standard animation |
| Rarely or once: success states, empty-state illustrations, celebration | Room for delight |

Tab switches never slide. Tabs are peers, not a hierarchy; sliding suggests a
depth that isn't there, and the user pays for it dozens of times a session.
Use `animation: 'none'`.

If the request fails this step, say so and don't write it.

## 2. What is it for?

Name the purpose before going on: **feedback**, **spatial consistency**,
**state indication**, **preventing a jarring change**, **explanation**, or
**delight** (only for things the user sees rarely). If you can't name one,
don't build it.

## 3. Pick the tool

Go down the table and stop at the first row that fits.

| Need | Tool |
| --- | --- |
| A state-driven change with no gesture: press, toggle, color, a value flipping | **Reanimated CSS transition** (`transitionProperty` in the style) |
| A loop, a multi-stage animation, or one that plays on mount | **Reanimated CSS animation** (`animationName` keyframes) |
| An element mounting or unmounting, or a list reflowing | **Layout animations** (`entering`, `exiting`, `itemLayoutAnimation`) |
| Anything a finger touches, or anything driven by scroll | **`useSharedValue` with `Gesture` and `useAnimatedStyle`** |
| Moving between screens | **Native stack options in Expo Router.** Never build this yourself |
| A bottom sheet that is its own screen | **`presentation: 'formSheet'`**, the platform's real sheet |
| A tab bar | **`NativeTabs`** (from `expo-router/unstable-native-tabs`), the platform's real tab bar |
| A context menu or press-and-hold preview | **`Link.Menu` / `Link.Preview`** (Expo Router, iOS only). Never rebuild these in JS |
| A header that collapses into a large title | **`headerLargeTitleEnabled`** on the native stack (iOS only; `headerLargeTitle` is deprecated), not a scroll worklet |
| Pull to refresh | **`RefreshControl`.** Build your own only for a signature interaction (see the threshold recipe) |
| UI that follows the keyboard | **`react-native-keyboard-controller`**, which tracks the keyboard's real position on the UI thread |
| An illustration, celebration, or empty state | **Lottie**, for illustration only, never for UI state |
| A huge animated scene or freeform drawing | **`@shopify/react-native-skia`**, a canvas for when the view hierarchy is the bottleneck |

Use a shared value only when the value is continuous or can be interrupted. A
press scale is a CSS transition; a drag is a shared value. A worklet for a
two-state toggle is overkill.

Install packages with `npx expo install <package>`. It picks the version that
matches the project's SDK, which `npm install` doesn't.

| Need | Package |
| --- | --- |
| Animation | `react-native-reanimated` and `react-native-worklets` |
| Gestures | `react-native-gesture-handler` |
| Navigation, sheets, native tabs, menus | `expo-router` |
| Haptics | `expo-haptics` |
| UI that follows the keyboard | `react-native-keyboard-controller` (needs `KeyboardProvider` at the root; see the keyboard recipe) |
| Illustration, celebration | `lottie-react-native` |
| Very large animated scenes, custom drawing | `@shopify/react-native-skia` |

## 4. Pick the properties

- **`transform` and `opacity` are cheap.** Everything else is a layout pass.
  `width`, `height`, `margin`, `padding`, `flex`, `top`, `left`, and `gap`
  re-run layout on every frame for that element and its siblings.
- **The exception is an absolutely positioned element with no children,** like
  a tab pill or a progress bar fill. It's out of the layout flow, so nothing
  else re-lays out, and animating `width` keeps the corner radius that
  `scaleX` would stretch.
- **Never start from `scale(0)`.** Start from `scale(0.9)` to `scale(0.97)`
  with `opacity: 0`.
- **Order matters in the `transform` array.** `[{ translateY }, { scale }]`
  scales after moving; reversed, the translation gets scaled too. Put
  translate first unless you want that.
- **Android shadows are `elevation`,** and animating it redraws the shadow
  every frame. Animate the opacity of a layer that already has the shadow.
- **Never animate `BlurView` intensity.** On Android it redraws the blur every
  frame. Crossfade the opacity of a static `BlurView` instead.
- **Percentages work in `translate`** and are relative to the element's own
  size, so `translateY('100%')` moves a sheet by its own height whatever its
  content.

## 5. Timing or spring

**If a finger is involved, use a spring.** Springs carry velocity through an
interruption; timing curves restart. Use timing for everything else.

Reanimated's spring accepts Apple's two designer parameters. Use this form,
not mass, stiffness, and damping:

| Interaction | Config |
| --- | --- |
| Default settle, no overshoot | `{ duration: 400, dampingRatio: 1 }` |
| Reposition or snap back after a drag | `{ duration: 400, dampingRatio: 0.8, velocity }` |
| Sheet, drawer | `{ duration: 300, dampingRatio: 0.8, velocity }` |
| Must not pass a hard edge | add `overshootClamping: true` |

Add bounce only when the gesture carried momentum. Overshoot on a menu that
faded in feels wrong; on a card the user flicked, it feels right.

**Easing,** for anything a finger isn't driving:

| Situation | Easing |
| --- | --- |
| Entering or exiting | `ease-out` |
| Moving or morphing on screen | `ease-in-out` |
| Constant motion (progress, marquee) | `linear` |
| Anything else | `ease-out` |

**Never use `ease-in` on UI.** It starts slow, delaying the moment the user is
watching. Reanimated's built-in curves are as weak as CSS's. Use these:

```js
import { Easing } from 'react-native-reanimated';

const EASE_OUT = Easing.bezier(0.23, 1, 0.32, 1);      // strong ease-out for UI
const EASE_IN_OUT = Easing.bezier(0.77, 0, 0.175, 1);  // on-screen movement
const EASE_SHEET = Easing.bezier(0.32, 0.72, 0, 1);    // iOS sheet curve
```

**Duration:**

| Element | Duration |
| --- | --- |
| Press feedback | 100–150ms |
| Toggle, chip, small state change | 150–200ms |
| Sheet, modal, drawer | A spring, about 300ms perceived |
| Screen transition | The platform default. Don't override it |

Keep mobile UI animations under 300ms, as on the web. The platform's own
transitions are longer (an iOS push is 350ms). Match the platform for
navigation, and be faster everywhere else.

## 6. Keep it off the JS thread

This is where most React Native motion goes wrong.

- **Never call `setState` from a gesture or scroll handler.** One React render
  per frame is the biggest cause of jank in React Native apps. Use a shared
  value and `useAnimatedStyle`, so React never re-renders.
- **Never call back to the React Native runtime inside `onUpdate` or a scroll
  handler.** `scheduleOnRN(fn, ...args)` from `react-native-worklets` (the
  Reanimated 4 replacement for the deprecated `runOnJS(fn)(...args)`) queues a
  call, and in `onUpdate` that runs 60–120 times a second. Put it in `onEnd`,
  or in a `useAnimatedReaction` that fires when a value crosses a threshold.
- **Never read a shared value during render** (`translateY.get()` in JSX). You
  get a snapshot that never updates. **Never write one during render either.**
  It runs mid-render, and any re-render repeats the write. Touch shared values
  only in worklets, handlers, and effects.
- **Use `.get()` and `.set()`, not `.value`.** They do the same thing, but the
  React Compiler can't see through `.value`. `set` also takes an updater:
  `sv.set((v) => v + 1)`.
- **Mark functions called from a worklet with `'worklet'`** as their first
  line. Without it they throw on device, even though they work in the
  debugger.

## 7. Press, not hover

Redesign every hover affordance from the web; don't port it.

- **Give feedback on press-in, act on press-out.** Waiting for the tap to finish
  before showing anything feels dead.
- **Scale to `0.97` in 100–150ms** on anything pressable, with `Pressable` and
  a CSS transition. The label and icons scale with it, which makes it read as
  physical.
- **Touch targets are at least 44×44pt (48dp on Android).** If the visual is
  smaller, add `hitSlop` instead of enlarging it.
- **Set `pressRetentionOffset`** so a finger drifting a few pixels doesn't
  cancel a press.
- **Use the Android ripple only in a Material-styled app.** In a custom design,
  the same scale on both platforms is more consistent.

## 8. Haptics

Used sparingly, haptics make an app feel well made. Used everywhere, users turn
them off.

| Moment | Call |
| --- | --- |
| A value ticks past a step: picker, slider detent, segmented control | `Haptics.selectionAsync()` |
| Something snaps home, a sheet detent catches, a drag commits | `Haptics.impactAsync(ImpactFeedbackStyle.Light)` |
| A heavy object lands, a destructive action fires | `Haptics.impactAsync(ImpactFeedbackStyle.Medium)` |
| An operation succeeded or failed | `Haptics.notificationAsync(NotificationFeedbackType.Success / Error)` |

Always follow these three rules:

- **Fire it in the same frame as the visual.** A haptic that lags its animation
  feels like a glitch. Fire it at the moment of cause (when the detent
  catches), not when the animation ends.
- **One per user action.** Never on scroll, never per frame, never on an
  entrance the user didn't cause.
- **Never as the only feedback.** Many users have haptics off, and most
  Android hardware is silent. The visual has to work alone.

From a worklet, schedule haptics back to the React Native runtime:
`scheduleOnRN(Haptics.selectionAsync)`.

## 9. Reduced motion and accessibility

```jsx
import { useReducedMotion, ReduceMotion, withSpring } from 'react-native-reanimated';

const reduced = useReducedMotion();
const y = useSharedValue(reduced ? 0 : SHEET_HEIGHT);

// or let each animation decide
withSpring(0, { duration: 300, dampingRatio: 0.8, reduceMotion: ReduceMotion.System });
```

Reduced motion means fewer and gentler animations, not none. Keep opacity and
color changes that explain a state change; drop movement, scale, parallax, and
overshoot. Screen transitions become `animation: 'fade'`.

Text scales. `allowFontScaling` is on by default, so a height measured at the
default text size is wrong at 200%. Never animate to a fixed height: measure
with `onLayout`, or animate a transform.

## Setup problems that silently break motion

Check these first when an animation doesn't run:

- Install through Expo so versions match the SDK:
  `npx expo install react-native-reanimated react-native-worklets`. In an Expo
  project, `babel-preset-expo` adds the worklets Babel plugin for you. A bare
  React Native project without that preset adds the plugin by hand, and it
  must be last in the list. A missing or misplaced plugin throws
  `Failed to create a worklet` at runtime.
- `GestureHandlerRootView` must wrap the app, or gestures do nothing and no
  error appears.
- Reanimated 4 requires the New Architecture.
- Expo Go is not for judging performance. Use a release build; a dev build's
  JS thread is slow enough to hide the problems you're looking for.

## 120fps

On ProMotion iPhones, third-party animations are capped at 60fps unless
`CADisableMinimumFrameDurationOnPhone` is set. Recent Expo SDKs set it by
default. Confirm it's there, and add it if not:

```json
{ "expo": { "ios": { "infoPlist": { "CADisableMinimumFrameDurationOnPhone": true } } } }
```

At 120fps the frame budget is 8ms, not 16, which is another reason to keep
animation on the UI thread.

## Recipes

[RECIPES.md](RECIPES.md) has ready implementations for: press feedback, a
drag-to-dismiss sheet, swipe to delete, a collapsing header, list entrances,
keyboard-synced UI, a tab indicator, screen transitions, toasts, and firing
once at a threshold. When the request matches one, start from the recipe.

## Never ship

| Never | Instead |
| --- | --- |
| `PanResponder` | `Gesture.Pan()` from gesture-handler |
| `setState` in a gesture or scroll handler | A shared value with `useAnimatedStyle` |
| `runOnJS` (deprecated in Reanimated 4) | `scheduleOnRN` from `react-native-worklets` |
| `scheduleOnRN` on every frame | `onEnd`, or `useAnimatedReaction` at a threshold |
| Reading or writing a shared value during render | `.get()` / `.set()` in worklets, handlers, and effects |
| Core `Animated` for anything a finger touches | Reanimated |
| Animating `height`, `width`, `margin`, `flex`, or `top` | `transform` and `opacity` (absolute, childless elements excepted) |
| Animating `BlurView` intensity or Android `elevation` | Crossfade a static layer |
| `entering` on a row in a virtualized list | Animate the container, or use `itemLayoutAnimation` |
| A screen transition rebuilt in JS | The native stack's `animation` option |
| Sliding between tabs | `animation: 'none'` |
| `Easing.in(...)` on a UI element | `Easing.bezier(0.23, 1, 0.32, 1)` |
| A `scale(0)` entrance | `scale(0.95)` with `opacity: 0` |
| Dismissing on distance only | Velocity or distance, so a flick is enough |
| A hard stop at a boundary | Rubber-band resistance |
| A haptic per frame, or as the only feedback | One per commit, always with a visual |
| Judging feel in Expo Go or the simulator | A release build on the slowest supported device |

## What to report

Write the code. Then add a few lines:

- **The decision:** how often the user sees it and the purpose you named. Say
  what you rejected and why.
- **The ingredients:** tool, properties, spring or curve and duration, and
  which thread it runs on.
- **What to check on a device:** gestures, velocity handoff, and haptic timing
  can't be judged from code. Say what to try: flick it, interrupt it
  mid-flight, reverse it, and run it on the slowest Android available.

Keep it short. The code is the deliverable.
