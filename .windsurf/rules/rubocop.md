---
trigger: glob
globs: **/*.rb, **/*.rake, Rakefile, Gemfile
---

# Ruby Code Style

## Rubocop Formatting

Always format Ruby code using Rubocop before completing changes.

<instructions>
1. After making changes, run `bundle exec rubocop -a` on modified files
2. If auto-correct fails, review the offenses and fix manually
3. Follow the project's `.rubocop.yml` configuration
4. Never disable Rubocop rules without explicit user approval
</instructions>
