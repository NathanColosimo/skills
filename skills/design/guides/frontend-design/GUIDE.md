# Frontend design

Give every design a point of view that fits its subject. Make deliberate
choices about palette, type, and layout for this brief, not the defaults you
would use for any page.

## Start from the subject

If the brief doesn't say what the product is, who it's for, and what the page
must do, propose one concrete answer for each and confirm it. Distinct choices
come from the subject's world: its industry, materials, and vocabulary. A toy
for 8-year-olds and a dashboard for analysts should look nothing alike. Use
the brief's real content throughout.

## Principles

- **Open with the most characteristic thing.** The first screen shows what's
  most specific to the subject: a headline, an image, a live demo, an
  interaction. A big number with a small label and a gradient accent is the
  default; use it only if it's truly the best option.
- **Typography carries the personality.** Use one or two families. If two,
  make them clearly different. Pick them for this brief, not out of habit. Set
  a clear type scale with deliberate weights and spacing. A headline's
  treatment is part of the design, not just a way to deliver words.
- **Keep lines under about 80 characters.** Serif body text can run slightly
  longer and needs a little more line height than sans-serif.
- **Structure carries information.** Borders, numbers, labels, and dividers
  should say something about the content. Use numbered markers (01, 02, 03)
  only when the content really is a sequence.
- **Use motion sparingly.** One orchestrated moment, like a single page-load
  sequence, beats effects scattered everywhere. A fade-up on every section and
  a hover effect on every card read as generated. Motion that responds to the
  user (opening, expanding, confirming) is welcome when it shows what changed.

Avoid these typographic defaults; they are the most common signs of a
generated page:

- highlighting one word in a headline with italics, bold, or color;
- all-caps labels;
- labels above content that add nothing.

## Avoid the generated look

Generated designs currently cluster around a few looks:

1. a warm cream background (near `#F4F1EA`), a high-contrast serif, and a
   terracotta accent (near `#D97757`);
2. a near-black background with one bright acid-green or vermilion accent;
3. a newspaper layout: hairline rules, square corners, dense columns;
4. the SaaS card kit: everything in identical rounded cards with the same
   soft shadow, one radius everywhere, and gradient washes;
5. template chrome: an all-caps eyebrow over every heading, meta text joined
   with middle dots (`A · B · C`), `WORD — fragment` labels, `#111` standing
   in for black, monospace for small labels, and `→` after every link.

Each is right for some brief, but they are defaults, not choices. If the
brief asks for one, follow the brief exactly. If it leaves a choice open,
don't spend it on one of these.

## Process

1. **Plan.** Write a short design plan:
   - Color: 4-6 named hex values.
   - Type: the typefaces and their roles.
   - Layout: a one-sentence concept and an ASCII wireframe, with alignment
     (left, center, justified).
   - Principles: what makes this page specific.
2. **Check the plan against the brief.** If any part is what you'd produce for
   any similar page, revise it. Say what you changed and why.
3. **Build** from the revised plan. Watch CSS specificity: a class selector
   like `.section` and an element selector like `.cta` can cancel each other's
   padding and margins.
4. **Critique** as you go. Take screenshots and look at them when you can.

## Restraint

Put the boldness in one place. Let one element be memorable, keep the rest
quiet, and cut decoration the brief doesn't need. Before you finish, remove one
more thing.

Meet the baseline without announcing it: responsive down to phone width,
visible keyboard focus, reduced motion respected, readable contrast, and a
palette that holds together.

## Writing

Words are there to make the design easier to understand and use.

- **Write from the user's side.** Name things the way users think of them:
  "notifications", not "webhook config". Say plainly what something does
  instead of selling it.
- **Buttons say what happens.** "Save changes", not "Submit". Keep the same
  word through the flow: a "Publish" button leads to a "Published" message.
- **Errors explain and direct.** Say what went wrong and how to fix it. Don't
  apologize and don't be vague.
- **Empty screens invite action.** Say what the user can do next.
- **Keep it plain.** Active voice, sentence case, no filler. Each piece of text
  does one job.

<!-- Modified from anthropics/skills (skills/frontend-design), Apache-2.0. See LICENSE.txt. -->
