---
trigger: glob
globs: app/jobs/**/*
---

# Job Guidelines

When creating or modifying jobs, follow these conventions.

1. Prefer passing the object rather than just the ID. Pass `user` instead of `user_id`. Active Job uses GlobalID to serialize and deserialize the record automatically.
```ruby
# Good
SomeJob.perform_later(user)

# Avoid
SomeJob.perform_later(user.id)
```

2. Jobs are automatically retried 10 times by Sidekiq. Do not add a `retry_count`, custom retry logic, or error handling unless there is a specific business need.

3. Jobs should contain minimum code. They should ideally just call methods on the model, service, or concern and avoid containing a lot of logic.
```ruby
# Good
class NotifyUserJob < ApplicationJob
  def perform(user)
    user.send_notification
  end
end

# Avoid
class NotifyUserJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)
    # lots of logic inline
  end
end
```
