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
