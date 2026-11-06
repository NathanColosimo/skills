---
name: design
description: UI design, polish, motion, and landing pages. Use when building or redesigning UI, choosing an aesthetic, polishing components, adding or reviewing animation and motion (web or Expo/React Native), stress-testing UI with worst-case data, or building a landing or marketing page.
---

# Design

This skill routes to detailed guides. Pick the guides that match the task,
read each one in full before you start, and follow it. Several can apply at
once, for example `frontend-design` with `animate`.

Paths below are relative to this skill's folder. Each guide lives in
`guides/<name>/GUIDE.md`, and the files it mentions sit next to it. The
guides were written as separate skills:

- When a guide names another one by its skill name (for example "use
  `review-animations`"), read `guides/<that name>/GUIDE.md`.
- When a guide's files say "SKILL.md", they mean that guide's `GUIDE.md`.
- Names a guide mentions that aren't listed below (like `expo-router`) are
  separate skills. Use them only if they are installed.

The project's own design system, tokens, and components come first. A guide
shapes how you use them. It doesn't replace them.

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
