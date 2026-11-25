---
trigger: glob
globs: app/models/**/*
---

# Validations

For each active record model make sure to add sensible validations
1. For date of birth fields make sure to prevent future dates
2. For email fields normalize email to downcase, ensure that email is unique, and validate the email format using the EmailValidator. normalize email like this `normalizes :email, with: ->(email) { email&.downcase }` and validate like this `validates :email, email: true, allow_blank: true`
3. If there are fields for start and end date on a model; then add a validation that the start date cannot be greater than the end date.

# Callbacks

For each active record model make sure to add sensible callbacks
1. For automatically capturing the user who created or last updated each record, include the Trackable concern
```ruby
include Trackable

This will automatically add the association and the callbacks.
```

2. Formatted ID generation
```ruby
after_create :set_formatted_id

def set_formatted_id
  update(formatted_id: "RE - #{id}")   # ReimbursementRequest
end
```

3. Record timestamp and user ID whenever a status field changes using store_accessor for accessors
```ruby
store_accessor :status_change_log, *statuses.keys.flat_map { |status| ["#{status}_at", "#{status}_by"] }

after_commit :update_status_change_log, if: -> { saved_change_to_status? }

def update_status_change_log
  update!("#{status}_at" => Time.current, "#{status}_by" => Current.user&.id)
end
```

