---
trigger: glob
globs: app/models/concerns/cm_admin/**/*
---

# CM Admin DSL Guidelines

When working with files in this directory, always reference the official documentation for the latest DSL methods and patterns.

## Documentation Reference

Before making changes, read the documentation only at:
https://docs.cm-admin.commutatus.com/docs

<instructions>
1. Before making changes, search the cm-admin documentation site for relevant DSL methods
2. Browse and navigate the docs site to find the appropriate page for the current task
3. Follow the patterns and methods described in the official docs
4. When unsure about any DSL syntax, always search the docs first
5. When creating new migrations ensure that the email field is always in citext
6. Use the appropriate field type for the field, email fields should have input_type: :email, for phone number fields use input_type: :phone
</instructions>
