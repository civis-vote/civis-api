---
trigger: glob
globs: db/migrate/**/*
---

# Migrations

When creating a new table in a migration, always add `created_by_id` and `updated_by_id` columns to track the user who created and last updated each record.

## Example

```ruby
create_table :posts do |t|
  t.string :title, null: false
  t.text :body

  t.references :created_by, foreign_key: { to_table: :users }
  t.references :updated_by, foreign_key: { to_table: :users }

  t.timestamps
end
```

## Instructions

1. Add `t.references :created_by` and `t.references :updated_by` to every new `create_table` block.
2. Point the foreign keys to the `users` table unless the application uses a different user model.
3. Make the references optional unless the requirement explicitly says otherwise.
4. In the corresponding Active Record model, include the `Trackable` concern so these columns are populated automatically.
