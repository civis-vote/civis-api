---
trigger: always_on
---

# Comment Style

## Minimize Comments

Write self-explanatory code instead of relying on comments. This applies to every file you edit, including
config, YAML, CI workflows, scripts, templates and stylesheets.

<instructions>
1. Do not add comments that restate what the code already expresses
2. Prefer clear names over explanatory comments
3. Only add comments to explain non-obvious "why" (business rules, workarounds, edge cases)
4. Keep a "why" comment to one line; if it needs more, put the explanation in the commit message or PR description
5. Never add or remove unrelated comments when editing a file
6. Do not add comments unless explicitly requested by the user, except the non-obvious "why" comments described in #3
</instructions>
