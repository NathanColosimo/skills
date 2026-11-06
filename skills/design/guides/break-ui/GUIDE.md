# Breaking UI

Take a piece of UI that looks right with demo data, feed it the realistic
worst case for every value it renders, put both datasets behind a toggle, and
report what broke. This guide finds breaks. For visual critique, use the
`emil-design-eng` guide. For motion, use the `review-animations` guide.

Demo data is usually picked, without anyone noticing, to make the design look
good: names that fit on one line, counts that never need a separator, every
optional field filled in. The UI was designed against "Jane Doe,
jane@acme.com, 12 members". Production has Aleksandra Wiśniewska-Kowalczyk, an
intern called Jo, and a workspace with 1,284 members. Undo the demo data's
choices one field at a time.

Two mistakes to avoid, the first one worse:

1. **Nonsense data.** `"aaaaaaaaaaaaaaaaaaaa"` or a 5,000-character name proves
   nothing, and the designer will rightly say "that never happens". Every
   worst-case value must be something a real user could produce, or the
   longest value the backend actually accepts.
2. **Stopping at long text.** Long names are the obvious break. The ones that
   ship are the short name that leaves an orphaned dash, the missing avatar,
   "1 members", the empty list, and the badge whose text got translated.

## Rules

1. **Realistic or schema-backed, never random.** Each value is a realistic
   example or the real limit from the validation schema, database column, or
   API contract. If there's no limit, that's a finding: write "unbounded" and
   test something long but believable.
2. **Change the data, not the component.** The worst case enters through the
   same place the demo data does: the fixture, the mock, the props, the API
   stub. Never edit markup or CSS to cause a break. That tests your edit, not
   the component.
3. **One dataset, many failures.** One worst-case dataset should hit every
   catalog row that applies. Spread them across rows (row 1 has the long name,
   row 2 the long email, row 3 the one-letter name), as real data does.
4. **The toggle is dev-only.** Gate it behind the dev environment or keep it in
   a prototype route. It never ships.
5. **Report before fixing.** Some breaks are design decisions (truncate or
   wrap? hide the role or show "—"?). List every break with a proposed fix,
   then stop. Fix only when asked.

## 1. Map what it renders

Read the component and list every value it renders, with its source:

| Field | Source | Type | Limit | Optional? |
| --- | --- | --- | --- | --- |
| `name` | `member.name` | string | 255 (`schema.ts:14`) | No |
| `email` | `member.email` | string | none found | No |
| `role` | `member.title` | string | 120 | Yes |
| `status` | enum | `active` / `invited` / `expired` | — | No |
| `count` | `workspace.memberCount` | int | — | No |

Include the values people forget: counts in headers, relative timestamps,
badge and status text, button labels that come from data, tooltips, avatar
images, and the length of the list itself.

Find limits in the validation schema (Zod, Yup, Valibot), database
migrations, API types, and form `maxLength` attributes. Note where frontend
and backend disagree. A 50-character input that saves to a 255-character
column will eventually receive something longer, through an import or the
API.

**Done when** every rendered value is in the table, with a source and either a
limit or "unbounded".

## 2. Build the worst case

Pick values for each field from [CATALOG.md](CATALOG.md). It covers text,
identifiers, numbers, collections, time, media, states, and environment, with
the specific values that break things and why.

Write one worst-case fixture next to the existing demo data, shaped exactly
like it (same type, same file conventions). The first few rows of a list
matter most because they're on screen, so spread the failures across them
instead of piling everything into row 1.

Also cover the cases one dataset can't:

- **Empty:** zero items and the no-results state.
- **One:** a single item, and every count at exactly 1, for plurals.
- **Huge:** the realistic upper bound for list length. Use 1,000+ rows for an
  unpaginated list; that's a performance break as well as a visual one.

Add these as extra toggle positions or extra fixtures. Don't skip them because
they don't fit a two-state toggle.

## 3. Wire the toggle

Add a segmented control labeled **Demo data / Worst case** that the user can
flip while looking at the component. Swap the fixture where the data comes
in (rule 2). Extra states become extra segments: **Demo / Worst case / Empty /
One / 1,000 rows**.

- **In a project with a dev server:** a dev-only switch, such as a
  `?data=worst` URL parameter read where the fixture is chosen, or a prototype
  route that renders the component with each fixture. Keep the choice in the
  URL so a reload keeps it.
- **A standalone component:** one self-contained HTML file with the component
  and every dataset inline.

Fix the toggle at the bottom center of the viewport, out of the component's
way. Keep it plain, since it isn't part of the design under test: a gray
track, a white pill on the active segment, the system font. Switch instantly,
with no animation on the content.

## 4. Break it

Look at the worst case for each failure below. Check it:

- at the component's **real container width** (a sidebar list isn't a
  full-page list), then at **320px** and at the **widest** layout it supports;
- at **200% browser zoom** or a larger root font size, because text grows and
  boxes don't;
- in **dark mode** and **RTL** (`dir="rtl"` on a wrapper), if the product
  supports them.

If you have browser tooling, screenshot both states at each width and compare.
If you don't, reason from the CSS, and say which findings you saw and which
you inferred.

### What breaks, why, and the fix

| What you see | Cause | Fix |
| --- | --- | --- |
| Avatar or icon squished into an oval | Flex child shrinking | `flex-shrink: 0` on the avatar, icon, and any fixed-size box |
| Text overflows its box instead of wrapping or truncating | Flex or grid child has `min-width: auto` | `min-width: 0` on the text column (`minmax(0, 1fr)` in grid) |
| Email or URL runs past the edge | No break points in the string | `overflow-wrap: anywhere` on that element |
| Trailing action (••• menu, button) pushed off-screen | The middle content took all the space | `min-width: 0` on the middle, `flex-shrink: 0` on the action |
| Badge wraps onto two lines | Badge allowed to shrink | `white-space: nowrap; flex-shrink: 0` on the badge, and decide what gives way instead |
| Avatar centered against a three-line name looks adrift | `align-items: center` on rows of varying height | `align-items: flex-start` once text can wrap |
| Last row cut off mid-glyph at a hard edge | Fixed-height container with no sign it scrolls | A visible scrollbar or a fade mask, and check the `overflow` is intended |
| A heading breaks mid-word | `word-break: break-all` | `overflow-wrap: anywhere`, which breaks only when it must |
| Wrong initials (`J` for "Jo", `CI` for "… Montgomery III", `�` for a name starting with an emoji) | `.split(' ')[0][0]`-style code | Initials from grapheme clusters (`Intl.Segmenter`), first and last word, a fallback icon |
| An orphaned `—` or empty line where the role was | Placeholder shown for a missing optional field | Omit the line, or reserve its height on purpose |
| "1 members", "0 member" | Hardcoded plural | `Intl.PluralRules`, or separate strings per count |
| Numbers jitter as they update; columns misalign | Proportional digits | `font-variant-numeric: tabular-nums` |
| `1284`, `1,284.000000001`, `NaN`, `undefined` | Raw number rendered | `Intl.NumberFormat` in the user's locale; guard null |
| A translated button label overflows | Fixed-width button | Size from content with `min-width`, never a fixed `width` |
| Diacritics or tall scripts (Vietnamese, Thai) clipped | Tight `line-height` with `overflow: hidden` | Looser `line-height`, or no clipping on text |
| Broken-image icon in the avatar | No `onError` fallback | Fall back to initials; `object-fit: cover` for any aspect ratio |
| Truncated text with no way to read it | `text-overflow: ellipsis` alone | A `title` or tooltip, and the full value somewhere else (a detail view) |
| Scrolling 1,000 rows stutters | Every row rendered | Virtualize or paginate, and say which |
| Raw `<b>`, `&amp;`, or `**text**` shows up | Escaping at the wrong layer | Escape once, at render. Never `dangerouslySetInnerHTML` user data |

### Truncate, wrap, or clamp

Every long string forces this choice. Decide per field:

- **Wrap** text the user needs in full to identify something: names, titles in
  a detail view. Two lines is usually fine. Four means the column is too
  narrow.
- **Truncate at the end** for secondary text whose start carries the meaning:
  a role, a description, a message preview. Always give a way to see the full
  value.
- **Truncate in the middle** when items differ at the end: file names
  (`Q3-report…v12-final.pdf`), emails with a shared long domain, paths,
  hashes. End truncation would make them look identical.
- **Clamp** (`line-clamp: 2`) multi-line previews in cards, so card heights
  stay predictable.
- **Never truncate** numbers, amounts, dates, or anything the user compares.
  Give them the room.

**Done when** every catalog row that applies has been tried, every width and
environment above is checked, and every break has a cause and a fix.

## 5. Report and stop

Report in the format below, leave the toggle running, and stop. The user flips
the toggle, looks, and decides.

## 6. Fix on request

Apply only the fixes the user picks, using the project's existing conventions
and tokens. Then flip through every state again, including Demo, since a fix
for the worst case must not break the demo. Confirm each fixed break is gone.

Keep the worst-case fixture afterward unless the user says otherwise. It's the
regression test for the next change to the component. The toggle stays
dev-only.

## Report format

### What broke

One row per break, worst first. Severity:

- **Broken:** content unreadable, an action unreachable, or wrong data shown.
- **Ugly:** readable but visibly wrong, like a squished avatar or a wrapped
  badge.
- **Fragile:** fine now, one realistic step from breaking, like no length
  limit or no fallback.

| # | Severity | Field | Worst-case value | What happens | Fix |
| --- | --- | --- | --- | --- | --- |
| 1 | Broken | `email` | `bartholomew.fitzgerald@northwind-industries-holdings.example.com` | Pushes the ••• menu off the row; unreachable at 400px | `min-width: 0` on the text column, `overflow-wrap: anywhere` on the email, `flex-shrink: 0` on the menu |
| 2 | Ugly | avatar | name with a long email | Avatar squishes to a 28×56 pill | `flex-shrink: 0` on the avatar |
| 3 | Ugly | `count` | 1 | "1 members" | `Intl.PluralRules` |
| 4 | Fragile | `name` | — | No max length in the schema or the form | Add the same limit to both |

Give the `file:line` of each fix, in the Fix cell or right below the table.

### Decisions for you

Breaks with more than one right answer: truncate or wrap a field, what an empty
role should show, whether a 1,000-row list paginates or virtualizes. One line
each, with your recommendation and why.

### What held up

List the worst cases the component already handles. It shows the test was
real and tells the user what not to touch.

End with where the toggle is (URL or file path), which states it has, and:
"Say `fix all` or `fix 1, 3` and I'll apply them."

If the user asks only for the data, build the fixture and the toggle and skip
the report. If they ask to fix as well, apply every fix that isn't in
"Decisions for you".
