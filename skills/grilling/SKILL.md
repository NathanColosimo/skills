---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

# Grilling

Question the user until you both understand the plan the same way.

Treat the plan as a **design tree**: each decision branches into the
decisions that depend on it.

## Rounds

Ask in rounds. Each round asks the whole **frontier**: every open decision
whose prerequisites are settled. Leave out a question whose answer depends
on another question in the same round. It goes in a later round.

Number each question and give your recommended answer. Word each one so
"yes" accepts your recommendation. Then stop and wait for the answers.

```
❓ **Q1** - **<title>**: <the question, with the options if there are several>

➡️ <your recommended answer>

---

❓ **Q2** - **<title>**: <the question>

➡️ <your recommended answer>
```

After each round, mark what's settled, find the new frontier, and ask the
next round.

## Facts and decisions

Facts are your job. If a question needs a fact you can look up (the code,
files, tools, docs), look it up instead of asking. For a long search, start
a subagent with a fresh context and ask the rest of the frontier while it
runs. Only the questions that depend on its answer wait.

Decisions are the user's. Put each one to them, and don't assume an answer.

## Done

You're done when the frontier is empty: every branch visited, nothing
assumed. List the settled decisions. Don't act on them until the user
confirms you share the same understanding.
