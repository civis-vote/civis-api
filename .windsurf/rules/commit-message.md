---
trigger: always_on
---

# Commit Message Format

When generating commit messages, follow the Conventional Commits specification:
use the @web to read conventional commits guidelines (https://www.conventionalcommits.org/en/v1.0.0/#summary)

- Format: `type(scope): single line description`
- Never add ``` block for commit message
- Types: feat, fix, refactor, docs, style, test, chore, perf, ci, build
- Keep the main message on a single line, clear and concise
- Add extra details as a markdown bullet list below if needed
- Each bullet point should include the reason why that change was made
- Where applicable, provide insight into the impact of not including the change

Example:

feat(auth): add OAuth2 login support

- Added Google OAuth provider — enables single-click login for Google Workspace users
- Updated user session handling — previous implementation lost sessions on token refresh
