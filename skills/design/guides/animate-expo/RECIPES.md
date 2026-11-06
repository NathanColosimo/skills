# Expo animation recipes

Starting points for the most common cases in a React Native app. Start from the recipe and adapt it.


## Setup the recipes assume

```bash
npx expo install react-native-reanimated react-native-worklets react-native-gesture-handler expo-haptics
```

Add `react-native-keyboard-controller` only for the keyboard recipe. Use `expo install`, not `npm install`, so versions match the SDK. `babel-preset-expo` sets up the worklets Babel plugin for you.

`GestureHandlerRootView` wraps the app once. In Expo Router, put it in the root `_layout`:

```jsx
import { GestureHandlerRootView } from 'react-native-gesture-handler';

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <Stack />
    </GestureHandlerRootView>
  );
}
```

Imports and constants the recipes below share:

```js
import { useState, useEffect, useMemo } from 'react';
import Animated, {
  useSharedValue, useAnimatedStyle, useAnimatedScrollHandler, useAnimatedReaction,
  withSpring, withTiming, interpolate, Extrapolation, Easing,
  FadeInDown, FadeOutDown, LinearTransition,
} from 'react-native-reanimated';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import { scheduleOnRN } from 'react-native-worklets';
import * as Haptics from 'expo-haptics';

const EASE_OUT = Easing.bezier(0.23, 1, 0.32, 1);      // strong ease-out for UI
const EASE_IN_OUT = Easing.bezier(0.77, 0, 0.175, 1);  // on-screen movement
const EASE_SHEET = Easing.bezier(0.32, 0.72, 0, 1);    // iOS sheet curve
```

Three conventions used throughout:

- **Read and write shared values with `.get()` and `.set()`.** The Reanimated docs recommend this form for the React Compiler. `.value` still works, but the compiler can't see through it.
- **Use `scheduleOnRN(fn, ...args)`** to call back to the React Native runtime from a worklet. It replaces the deprecated `runOnJS(fn)(...args)`.
- **Wrap gestures in `useMemo`.** Rebuilding a gesture on every render can reattach the recognizer and drop a drag in progress.

**Gesture Handler v3:** Expo installs v2, and the recipes use its `Gesture.Pan()` builder. On v3 the builder is legacy. Each gesture is a hook that takes one config object: `onStart` becomes `onActivate`, `onEnd` becomes `onDeactivate`, and the `success` flag becomes `event.canceled` (inverted). The hook keeps its own identity, so drop the `useMemo`:

```jsx
const pan = usePanGesture({
  activeOffsetY: [-10, 10],
  onActivate: () => { context.set(translateY.get()); },
  onUpdate: (e) => { translateY.set(context.get() + e.translationY); },
  onDeactivate: (e) => { /* settle with withSpring as below */ },
});
```


## Two worklets used everywhere

Momentum projection works out where a flick was heading, so a fast short swipe commits and a slow long one doesn't. Rubber-banding makes a boundary resist instead of stopping dead.

```js
// Where the finger would come to rest if it kept decelerating.
// Apple's exponential-decay form, not the v²/2a from physics class.
function project(velocity, decelerationRate = 0.998) {
  'worklet';
  return ((velocity / 1000) * decelerationRate) / (1 - decelerationRate);
}

// The further past the edge, the less the element follows.
function rubberband(overshoot, dimension, constant = 0.55) {
  'worklet';
  return (overshoot * dimension * constant) / (dimension + constant * Math.abs(overshoot));
}
```


## Press feedback

For every pressable in the app. It passes step 1 in [GUIDE.md](GUIDE.md) only because it's barely noticeable: 120ms and a 3% scale is the limit for something touched this often. Anything longer or larger is for rarer moments. There's no gesture and no shared value; a CSS transition is the whole implementation.

```jsx
import Animated from 'react-native-reanimated';
import { Pressable, StyleSheet } from 'react-native';

function PressableScale({ onPress, children }) {
  const [pressed, setPressed] = useState(false);
  return (
    <Pressable
      onPress={onPress}
      onPressIn={() => setPressed(true)}
      onPressOut={() => setPressed(false)}
      hitSlop={12}
      pressRetentionOffset={16}
    >
      <Animated.View style={[styles.box, pressed && styles.pressed]}>{children}</Animated.View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  box: {
    transform: [{ scale: 1 }],
    transitionProperty: 'transform',
    transitionDuration: '120ms',
    transitionTimingFunction: 'cubic-bezier(0.23, 1, 0.32, 1)',
  },
  pressed: { transform: [{ scale: 0.97 }] },
});
```

`setState` is fine here: it runs twice per press, not every frame. `hitSlop` brings a small icon up to the 44pt target without enlarging it, and `pressRetentionOffset` stops a slight finger drift from canceling the press.


## Bottom sheet you can drag to dismiss

If the sheet is its own screen, use `presentation: 'formSheet'` instead (see **Screen transitions**) and get the platform's real sheet. Build this only when the sheet has to live inside an existing screen.

```jsx
const translateY = useSharedValue(0);
const context = useSharedValue(0);

const pan = useMemo(() => Gesture.Pan()
  .activeOffsetY([-10, 10])   // let a horizontal swipe win; require clear intent before committing
  .onStart(() => {
    context.set(translateY.get());   // start from the current on-screen value, not from 0
  })
  .onUpdate((e) => {
    const next = context.get() + e.translationY;
    // downward is free; upward past the top resists
    translateY.set(next >= 0 ? next : rubberband(next, HEIGHT));
  })
  .onEnd((e) => {
    const projected = translateY.get() + project(e.velocityY);
    if (projected > HEIGHT * 0.4) {
      translateY.set(withSpring(HEIGHT, {
        duration: 300, dampingRatio: 1, velocity: e.velocityY, overshootClamping: true,
      }, (finished) => { if (finished) scheduleOnRN(onClose); }));
    } else {
      translateY.set(withSpring(0, { duration: 300, dampingRatio: 0.8, velocity: e.velocityY }));
      scheduleOnRN(Haptics.impactAsync, Haptics.ImpactFeedbackStyle.Light);   // it snapped home
    }
  }), [onClose]);

const sheetStyle = useAnimatedStyle(() => ({ transform: [{ translateY: translateY.get() }] }));
```

Get these four details right:

- **`onStart` captures the current value.** Without it, grabbing a sheet mid-animation makes it jump. The motion must continue from where the user last saw it.
- **Velocity decides, not distance.** With `project()`, a quick flick dismisses even a few pixels down. Requiring 40% travel makes the sheet feel heavy.
- **Pass the velocity to the spring,** so there's no seam between the finger lifting and the animation continuing. This detail matters most.
- **Set `overshootClamping` on dismissal.** Otherwise the sheet springs past the bottom of the screen and flashes a gap.

Derive the backdrop from the same value, so it stays in sync for free:

```jsx
const backdropStyle = useAnimatedStyle(() => ({
  opacity: interpolate(translateY.get(), [0, HEIGHT], [1, 0], Extrapolation.CLAMP),
}));
```


## Swipe to delete a row

Gesture Handler ships [`ReanimatedSwipeable`](https://docs.swmansion.com/react-native-gesture-handler/docs/components/reanimated_swipeable/), which already handles swipe-to-reveal actions (thresholds, overshoot, open and close methods) on the UI thread. Use it when the row reveals action buttons. Build the gesture yourself only for a different interaction, like this swipe-to-commit with momentum projection.

```jsx
const x = useSharedValue(0);
const context = useSharedValue(0);

const pan = useMemo(() => Gesture.Pan()
  .activeOffsetX([-10, 10])   // must declare the axis, or it fights the vertical scroll
  .onStart(() => { context.set(x.get()); })   // grabbing mid-spring continues from where the row is, not from 0
  .onUpdate((e) => { x.set(Math.min(0, context.get() + e.translationX)); })
  .onEnd((e) => {
    const projected = x.get() + project(e.velocityX);
    if (projected < -SWIPE_THRESHOLD) {
      x.set(withTiming(-WIDTH, { duration: 200, easing: EASE_OUT }, (f) => {
        if (f) scheduleOnRN(onDelete, id);
      }));
    } else {
      x.set(withSpring(0, { duration: 300, dampingRatio: 1, velocity: e.velocityX }));
    }
  }), [onDelete, id]);
```

The list, not the row, closes the gap the deleted row leaves:

```jsx
const ROW_CLOSE = LinearTransition.duration(200);   // module scope: a builder rebuilt in render costs every re-render

<Animated.FlatList data={items} itemLayoutAnimation={ROW_CLOSE} ... />
```

`activeOffsetX` matters most here. A pan handler inside a scroll view with no axis declared steals vertical scrolls, and the list feels broken in a way that looks like a scrolling bug rather than a gesture bug.


## Collapsing header on scroll

```jsx
const scrollY = useSharedValue(0);
const onScroll = useAnimatedScrollHandler((e) => { scrollY.set(e.contentOffset.y); });

const titleStyle = useAnimatedStyle(() => ({
  opacity: interpolate(scrollY.get(), [0, 60], [1, 0], Extrapolation.CLAMP),
  transform: [{ translateY: interpolate(scrollY.get(), [0, 60], [0, -12], Extrapolation.CLAMP) }],
}));

<Animated.ScrollView onScroll={onScroll} scrollEventThrottle={16}>
```

**Never animate the header's `height` to collapse it.** That runs layout on the header and everything below it on every scroll frame, competing with the scroll itself, so it always stutters. Give the container a fixed height, translate the content inside it, and clip with `overflow: 'hidden'`.

`Extrapolation.CLAMP` is required. Without it, scrolling past 60 keeps pushing opacity negative and the header reappears at the bottom of a long list.


## List entrances

```jsx
// Build layout animations outside components or in useMemo; an inline chain
// in JSX rebuilds the builder on every render. A per-index delay can't live
// at module scope, so each row memoizes its own:
function Row({ item, index }) {
  const entering = useMemo(() => FadeInDown.duration(250).delay(index * 40), [index]);
  return <Animated.View entering={entering}>{/* ... */}</Animated.View>;
}

{items.map((item, i) => <Row key={item.id} item={item} index={i} />)}
```

Stagger by 30–80ms. Longer feels slow; shorter looks simultaneous.

**Never put `entering` on a row inside `FlatList`, `FlashList`, or any virtualized list.** Rows are recycled, so the animation runs again every time a row scrolls back into view, and the list flickers while scrolling. Animate the list container once on mount, or use `itemLayoutAnimation` for reflow only.

Entrance animations are for content the user asked for and is waiting on. A list they scroll past all day should simply be there.


## Keyboard-synced UI

This needs its own package and a provider at the root ([Expo keyboard guide](https://docs.expo.dev/guides/keyboard-handling/)):

```bash
npx expo install react-native-keyboard-controller
```

```jsx
import { KeyboardProvider } from 'react-native-keyboard-controller';

// Root _layout, next to GestureHandlerRootView. The hooks do nothing without it.
<KeyboardProvider>
  <Stack />
</KeyboardProvider>
```

```jsx
import { useReanimatedKeyboardAnimation } from 'react-native-keyboard-controller';

const { height } = useReanimatedKeyboardAnimation();   // 0 to -keyboardHeight, on the UI thread
const footerStyle = useAnimatedStyle(() => ({ transform: [{ translateY: height.get() }] }));
```

Never build this from `Keyboard.addListener` and a timing animation. The keyboard follows a private system curve, the event reaches the JS thread after the keyboard has started moving, and any duration you pick will visibly lag or lead it. Drive the UI from the keyboard's actual position, frame by frame.


## Tab / segmented indicator

Measure once, then animate transforms.

```jsx
const [layouts, setLayouts] = useState({});   // measured with onLayout, not per frame
const x = useSharedValue(0);
const w = useSharedValue(0);

useEffect(() => {
  const l = layouts[active];
  if (!l) return;
  x.set(withTiming(l.x, { duration: 250, easing: EASE_IN_OUT }));
  w.set(withTiming(l.width, { duration: 250, easing: EASE_IN_OUT }));
}, [active, layouts]);

const pillStyle = useAnimatedStyle(() => ({
  transform: [{ translateX: x.get() }],
  width: w.get(),
}));
```

This is the allowed `width` animation: the pill is absolutely positioned with no children, so nothing else re-lays out, and its corners stay round. `scaleX` would stretch them into ovals.

It uses `ease-in-out` because the pill moves across the screen rather than entering or leaving it. Fire `Haptics.selectionAsync()` on the press, not when the pill lands.


## Screen transitions (Expo Router)

Configure the native stack. Never rebuild a screen transition in JS: the native one runs on the platform side, keeps the interactive back gesture, and matches every other app on the device.

```jsx
<Stack screenOptions={{ animation: reduced ? 'fade' : 'default' }}>
  <Stack.Screen name="settings" options={{ animation: 'slide_from_right', animationMatchesGesture: true }} />
  <Stack.Screen name="compose" options={{ presentation: 'modal' }} />
  <Stack.Screen name="filter" options={{
    presentation: 'formSheet',
    sheetAllowedDetents: 'fitToContents',
    sheetGrabberVisible: true,
  }} />
</Stack>
```

| Navigation | Option |
| --- | --- |
| Deeper into a hierarchy | `animation: 'default'`, the unmodified platform push |
| A self-contained task the user can abandon | `presentation: 'modal'` |
| A short interruption: picker, filter, share | `presentation: 'formSheet'` with detents |
| Between tabs | `animation: 'none'` |
| Reduced motion | `animation: 'fade'` |

`animationMatchesGesture: true` makes the iOS back swipe play your transition in reverse under the finger, instead of the default push. Set it whenever you set a custom `animation`, or swiping back looks different from going forward.

`formSheet` is native on both platforms, but they differ. The [Expo modal docs](https://docs.expo.dev/router/advanced/modals/#form-sheet-presentation) have the full list:

- **Android allows at most three detents.** A longer `sheetAllowedDetents` array works on iOS and is silently cut on Android. Design for three.
- **`sheetGrabberVisible` is iOS only.** Android shows no grabber, so don't rely on it as the only sign the sheet can be dragged.
- **Android form sheets can't hold native headers or nested stacks.** Keep the sheet to a single screen. If it needs its own navigation, use `presentation: 'modal'`.
- **`fitToContents` needs content with an explicit size.** A `flex: 1` root has no natural height to fit, so the detent comes out wrong.


## Toast

```jsx
// Module scope: layout animation builders live outside the component.
const TOAST_ENTER = FadeInDown.duration(300).easing(EASE_OUT);
const TOAST_EXIT = FadeOutDown.duration(250).easing(EASE_OUT);

<Animated.View
  entering={TOAST_ENTER}
  exiting={TOAST_EXIT}
  style={{ position: 'absolute', bottom: insets.bottom + 16, left: 16, right: 16 }}
/>
```

- **The 300ms limit applies.** The user didn't ask for a toast, so it should be quicker and quieter than motion they did ask for.
- **Exit the way it entered.** Entering from the bottom and leaving to the side looks like two unrelated elements.
- **Exit about 20% faster than it entered.** By then the user has finished reading it.
- **Always respect safe area insets.** A toast at `bottom: 16` sits under the home indicator on every modern iPhone.

If toasts stack and the list reflows, add `itemLayoutAnimation` and tune the opacity against the reflow by eye. There's no formula for that pair. Look at it again the next day.


## Firing something once at a threshold

When crossing a point matters (a detent, a snap, pull-to-refresh arming), don't poll it from JS and don't call `scheduleOnRN` every frame.

```jsx
const armed = useSharedValue(false);

useAnimatedReaction(
  () => pullDistance.get() > REFRESH_THRESHOLD,
  (isArmed, wasArmed) => {
    if (isArmed !== wasArmed) {
      armed.set(isArmed);
      scheduleOnRN(Haptics.impactAsync, Haptics.ImpactFeedbackStyle.Light);
    }
  }
);
```

The comparison runs on the UI thread every frame, and the JS call happens twice per pull. Use this pattern whenever something should happen when an animation reaches a point.
