---
trigger: glob
globs: app/services/**/*.rb
---

# Service Object Guidelines

When creating or modifying service objects, follow these conventions.

1. Return a result hash for expected outcomes instead of raising. Callers should be able to handle failure without rescuing.
```ruby
# Good
{ success: true, transcription: text, errors: [] }
{ success: false, transcription: nil, errors: [message] }

# Avoid
raise TranscriptionError, message
```

2. Keep the result shape stable across success and failure — always include `success` and `errors` keys so callers can pattern-match on `result[:success]`.

3. Distinguish domain failures from unexpected errors — e.g. an inaudible audio file is an expected outcome (flag it in the result), not an exception.

4. Use `call` as the single entry point and pass dependencies through the constructor, not the call arguments.

5. For AI-backed services, keep prompts in `config/prompts/` as text files with `{{UPPERCASE}}` placeholders interpolated by a prompt service — static instructions first, dynamic context last for prompt caching.
