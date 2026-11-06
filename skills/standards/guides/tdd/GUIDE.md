# Test-driven development

Write one failing test, make it pass with the least code, and repeat. The
point is tests worth keeping: they check behavior, survive refactors, and fail
for real regressions.

Examples are in [tests.md](tests.md). When to mock is in
[mocking.md](mocking.md).

## Pick the seams first

A seam is the public interface where you test: a function's signature, an
HTTP endpoint, a rendered component. Tests go at seams, never against
internals.

Before writing tests, write down which seams you'll test and what each one
catches. Spend tests on the critical paths and the tricky logic, not on every
edge case. If the right seam isn't clear, ask the user before you start.

## The loop

1. **Red.** Write one test for the next behavior. Run it and watch it fail for
   the reason you expect.
2. **Green.** Write the least code that makes it pass. Don't build for tests
   you haven't written yet.
3. **Repeat.** One behavior per cycle. Let each cycle shape the next test.

Once everything is green, run the `standards` simplify pass. Refactoring is a
separate step from the loop.

## Mistakes to avoid

- **Testing internals.** Mocking your own modules, testing private functions,
  or checking the database instead of the interface. If a refactor that keeps
  behavior breaks the test, the test is wrong.
- **Restating the code.** An expected value computed the same way the code
  computes it (`expect(add(a, b)).toBe(a + b)`) can never fail. Use a literal
  you know is right, a worked example, or the spec.
- **Writing all the tests first.** A batch of tests written before any code
  checks what you imagined, not what you learned. Go one test at a time.
