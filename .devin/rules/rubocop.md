---
trigger: glob
globs: **/*.rb, **/*.rake, Rakefile, Gemfile
---

# Ruby Code Formatting

Format Ruby code with the formatter configured by the repository. Do not run both formatters.

## Choose the Formatter

<instructions>
1. Check the repository's `Gemfile`/`Gemfile.lock` and formatter configuration.
2. If the repository uses the `standard` gem or has Standard Ruby configuration (such as `.standard.yml`), use Standard Ruby and follow the `standard-format` skill.
3. Otherwise, use RuboCop and follow the `rubocop-format` skill.
4. Run only the selected formatter on the modified Ruby files.
</instructions>
