---
trigger: glob
globs: **/*.scss, **/*.css, **/*.sass
---

# CSS/SCSS Variables Rule

## No Hardcoded Hex Colors

Never use hardcoded hex color values directly in SCSS or CSS files. Always use the project's SCSS variables defined in `app/assets/stylesheets/cm_admin/helpers/_variable.scss`.

## Available SCSS Color Variables

### Brand Colors
- `$brand-color` → `#6554e0`
- `$brand-hover-color` → `#e6e4fa`
- `$sidebar-bg-color` → `#252525`
- `$sidebar-item-hover-color` → `#ffffff1a`
- `$nested-section-color` → `#f2f3f5`

### Semantic Colors
- `$informative-clr` → `#2f80ed`
- `$error-clr` → `#f83636`
- `$warning-clr` → `#ffc845`
- `$positive-clr` → `#30c39e`
- `$disabled-clr` → `#9ca7ae`

### Blue
- `$blue-regular-clr` → `#2f80ed`
- `$blue-light-clr` → `#cde1fb`
- `$blue-lightest-clr` → `#eef5fe`

### Red
- `$red-regular-clr` → `#f83636`
- `$red-light-clr` → `#fdcfcf`
- `$red-lightest-clr` → `#feefef`

### Yellow
- `$yellow-regular-clr` → `#ffc845`
- `$yellow-light-clr` → `#ffefc7`
- `$yellow-lightest-clr` → `#fff8e9`

### Green
- `$green-regular-clr` → `#30c39e`
- `$green-light-clr` → `#c1ede2`
- `$green-lightest-clr` → `#eefaf7`

### Grey
- `$grey-regular-clr` → `#c7ced5`
- `$grey-light-clr` → `#d9dee3`
- `$grey-lighter-clr` → `#f3f4f6`
- `$grey-lightest-clr` → `#f8f9fa`
- `$grey-dark-clr` → `#828282`
- `$card-grey-lighter-clr` → `#f3f4f6`
- `$dropdown-border-clr` → `#e0e0e0`
- `$btn-group-border-clr` → `#dee2e6`

### Ink / Text
- `$ink-regular-clr` → `#212529`
- `$ink-light-clr` → `#3b4352`
- `$ink-lighter-clr` → `#6b7586`
- `$ink-lightest-clr` → `#9ca7ae`
- `$ink-secondary-clr` → `#6c757d`
- `$floating-label-color` → `rgba(33, 37, 41, 0.65)`
- `$primary-text-clr` → `#212529`
- `$subdued-text-clr` → `#d9dee3`

### Common
- `$white` → `#ffffff`
- `$black` → `#000000`

### Scrollbar
- `$scrollbar-track-clr` → `#f1f1f1`
- `$scrollbar-thumb-clr` → `#c1c1c1`
- `$scrollbar-thumb-hover-clr` → `#a8a8a8`

<instructions>
1. Scan all modified SCSS/CSS files for hardcoded hex color values (e.g., `#fff`, `#6554e0`, `rgba(...)` with raw numbers).
2. For each hardcoded color found, check if a matching variable exists in `app/assets/stylesheets/cm_admin/helpers/_variable.scss`.
3. If a matching variable exists, replace the hardcoded value with the SCSS variable.
4. If no matching variable exists for a new color, add a new named variable to `_variable.scss` under the appropriate section (Brand, Semantic, Grey, Ink, etc.) and then use it in the file.
5. Never leave a hardcoded hex color in the codebase when adding or modifying styles — always resolve it to a variable.
6. When reviewing pull requests, flag any hardcoded hex colors as required changes and suggest the correct variable name or propose adding one.
</instructions>
