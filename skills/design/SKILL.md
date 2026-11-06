---
name: design
description: UI design, polish, motion, and landing pages. Use when building or redesigning UI, choosing an aesthetic, polishing components, adding or reviewing animation and motion (web or Expo/React Native), stress-testing UI with worst-case data, or building a landing or marketing page.
---

# Design

This skill routes to detailed guides. Pick the guides that match the task,
read each one in full before you start, and follow it. Several can apply at
once, for example `frontend-design` with `animate`.

Paths below are relative to this skill's folder. Each guide lives in
`guides/<name>/GUIDE.md`, and the files it mentions sit next to it. When a
guide points to another guide by name, read `guides/<that name>/GUIDE.md`.
The animation values all guides share (frequency, easing, durations, springs)
are in `guides/review-animations/STANDARDS.md`.

The project's own design system, tokens, and components come first. A guide
shapes how you use them. It doesn't replace them.

## Rules for every screen

These apply whichever guide you use.

- **Every element earns its space.** Each heading, button, status line, and
  border must help the user understand or do something. Remove headings that
  repeat what's obvious, status text that says nothing new ("Viewing
  computer"), and containers that only mark where one component ends.
- **One control per intent.** If two buttons do the same thing, merge them,
  or make the difference clear in the user's words.
- **Keep secondary actions out of the way.** Admin and lifecycle actions (stop,
  delete, reset) go somewhere deliberate, not permanently on the main screen.
  Don't hide a truly essential action just to cut the button count.
- **Review the whole screen,** not each component alone. A page header, a
  toolbar, and an embedded viewer's toolbar are one experience.
- **Loading looks like the loaded layout.** The pending state uses the same
  frame, alignment, and markers as the content, so nothing jumps when data
  arrives. Don't show fake data or enabled actions before it does.
- **Keep content on screen during a refresh,** including after a refresh
  fails. Show the error next to it.
- **Progress shows on the trigger.** The button that started an action shows
  its progress ("Save" → "Saving…") and keeps its size. Don't add a separate
  "Saving…" row.
- **Errors appear next to what failed** and stay until resolved. Use a toast
  only when there's no better place.
- **Test the transitions,** not just the final screenshot: loading to content,
  error to retry to success, on desktop and narrow screens, with long text.

## Which guide

| Task | Guide |
| --- | --- |
| Build new UI or reshape an existing one; pick an aesthetic direction and typography | `frontend-design` |
| Polish components and the small details that make UI feel good; design critique | `emil-design-eng` |
| Build a landing page, marketing site, or company site, or fix a page that looks generic or "AI-made" | `taste` (see below) |
| Animate something on the web: transitions, motion, making a component feel alive | `animate` |
| Animate in Expo or React Native: gestures, sheets, screen transitions, press feedback, haptics | `animate-expo` |
| Critique existing animation or motion code | `review-animations` |
| Audit a whole codebase's motion and plan improvements | `improve-animations` |
| Find places that should animate but don't | `find-animation-opportunities` |
| Stress-test UI with worst-case data: long text, empty states, huge numbers, other scripts | `break-ui` |

## taste

`taste` is the [taste-skill](https://github.com/leonxlnx/taste-skill) kit for
landing and marketing pages. It is too large to copy here (about 40 MB of
assets), so fetch it when you need it:

```bash
cache="$HOME/.cache/taste-skill"
if [ -d "$cache/.git" ]; then git -C "$cache" pull -q --ff-only; else git clone -q --depth 1 https://github.com/leonxlnx/taste-skill "$cache"; fi
```

Then read `$HOME/.cache/taste-skill/skills/taste-skill/SKILL.md` and follow
it. Where it says `<skill>`, it means
`$HOME/.cache/taste-skill/skills/taste-skill`. It needs Node 22 or later and
a Chromium browser for its checks.

Use it for standalone marketing pages. Inside an existing product with its
own design system, use `frontend-design` and `emil-design-eng` instead.
