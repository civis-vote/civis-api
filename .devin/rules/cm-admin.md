---
trigger: glob
globs: app/models/concerns/cm_admin/**/*
---

# CM Admin DSL Guidelines

When working with files in this directory, always reference the official documentation for the latest DSL methods and patterns.

## Documentation Reference

The cm-admin gem ships its documentation as Markdown, matching the version in `Gemfile.lock`. Read it locally instead of fetching the website:

```bash
CM_ADMIN_DOCS="$(bundle info cm-admin --path)/docs-site/docs"
grep -rl "<dsl_method>" "$CM_ADMIN_DOCS"   # find the page for a DSL method
```

The DSL reference is `2. Views/DslMethods.md`; the other Views pages cover each action.

<instructions>
1. Before making changes, search the bundled cm-admin docs for relevant DSL methods
2. Read the page that covers the current task
3. Follow the patterns and methods described in the official docs
4. When unsure about any DSL syntax, always search the bundled docs first
5. When creating new migrations ensure that the email field is always in citext
6. Use the appropriate field type for the field, email fields should have input_type: :email, for phone number fields use input_type: :phone
</instructions>

## Permission-Based Access Control

Always use permission-based methods instead of role checks when controlling access to features, fields, or actions.

### Add these methods to your User model

First, add the following permission helper methods to your User model:

```ruby
def permission_with_scope?(model_name:, action_name:, scope_name:)
  cm_role.cm_permissions.where(ar_model_name: model_name, action_name:, scope_name:).exists?
end

def has_permission?(model_name, action_name)
  return false unless cm_role.present?

  cm_role.cm_permissions.exists?(ar_model_name: model_name, action_name: action_name)
end
```

### Use `permission_with_scope?` for scoped permissions

When checking permissions with a specific scope (e.g., 'all', 'own', 'team'):

```ruby
unless Current.user.permission_with_scope?(model_name: 'ReimbursementRequest', action_name: 'revert_acknowledged', scope_name: 'all')
  # Handle unauthorized access
end
```

### Use `has_permission?` for general permissions

When checking permissions without a scope:

```ruby
column :note_type, header: 'Note Type', field_type: :enum, display_if: lambda { |_|
  ::Current.user.has_permission?('Customer', 'customer_restricted_fields')
}
```

### Never use role checks

Avoid using role-based checks like:
- `Current.user&.role?('admin')`
- `Current.user.cm_role.name == 'admin'`

Instead, always use the permission methods defined above which provide fine-grained access control based on the user's role permissions.
