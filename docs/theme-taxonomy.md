# Theme Taxonomy — icons, status, and canonical lists

Follow-up work to CIV-166. Adds `icon_name` and a `status` enum to themes,
moves the canonical theme/segment name lists onto their models, and retires
`cover_photo` from themes.

- PR (stacked on CIV-166): <https://github.com/civis-vote/civis-api/pull/1361>
- Staging PR: <https://github.com/civis-vote/civis-api/pull/1363>
- Icon source: [Figma — Civis AntD Platform, Theme tag set](https://www.figma.com/design/PIRxvAmQnoBB1mg6Lt4upV/Civis-AntD-Platform?node-id=30958-27661)

## Data model

| Change | Detail |
| ------ | ------ |
| `themes.icon_name` | `string`, nullable — Font Awesome class, e.g. `fas fa-bolt` |
| `themes.status` | `integer` enum, `0 = active`, `1 = disabled`, default `active` |
| `cover_photo` | Removed from the model (`has_one_attached`), cm-admin, and GraphQL |

## Canonical lists

The name lists moved out of `config/initializers/constants.rb` (which now only
holds `CONSTANT_TYPES` and `DEFAULT_PER_PAGE`):

- `Theme::CIVIS_THEMES` — `Hash` of theme name → Font Awesome icon class
- `Theme::CIVIS_THEME_NAMES` — derived `CIVIS_THEMES.keys`
- `Constant::SEGMENT_NAMES` — segment names (`constant_type: :segment`)

### Theme → icon map (from Figma)

| Theme | icon_name | | Theme | icon_name |
| ----- | --------- |-| ----- | --------- |
| Accessibility | `fas fa-universal-access` | | Labour | `fas fa-briefcase` |
| Agriculture | `fas fa-leaf` | | Legal Affairs | `fas fa-scale-balanced` |
| Consumer Affairs | `fas fa-cart-shopping` | | Media | `fas fa-images` |
| Education | `fas fa-book-open` | | Public Administration | `fas fa-landmark` |
| Energy | `fas fa-bolt` | | Rural Development | `fas fa-tractor` |
| Environment | `fas fa-tree` | | Telecom | `fas fa-satellite-dish` |
| Finance | `fas fa-chart-line` | | Tourism | `fas fa-plane` |
| Food Safety | `fas fa-utensils` | | Transport | `fas fa-truck` |
| Gender | `fas fa-venus-mars` | | Urban Settlements | `fas fa-city` |
| Health | `fas fa-heart-pulse` | | Youth and Sports | `fas fa-person-running` |
| Industry | `fas fa-gears` | | Insurance | `fas fa-shield-check` ⚠️ |
| Internet | `fas fa-globe` | | | |

⚠️ `fa-shield-check` is a **Font Awesome Pro** glyph — it renders nothing under
FA Free. Use `fas fa-shield-alt` as the free fallback if needed.

## cm-admin

- Index + show expose `name`, `icon_name` (string with Font Awesome helper
  text), and `status` as a badge (`active` → green, `disabled` → red via
  `STATUS_TAG_COLORS`).
- Custom actions on the show page, mirroring `disable_user`/`activate_user`:
  - `Disable Theme` — `PATCH :id/disable_theme`, modal confirm, shown when `active?`
  - `Activate Theme` — `PATCH :id/activate_theme`, modal confirm, shown when `disabled?`

## GraphQL

- `Theme` type exposes `iconName` (nullable). `coverPhoto` was **removed** —
  frontend queries must drop it (**breaking change**).
- Disabled themes are filtered out everywhere themes surface:
  - `themeList` query (`Theme.active`)
  - `Consultation.themes`
  - `CurrentUser.preferred_themes`
- Model associations are untouched — `consultation.themes` in Rails still
  returns disabled themes; only GraphQL output is scoped.

## Rake tasks

| Task | Behaviour |
| ---- | --------- |
| `import_records_from_array:themes_and_segments` | Creates/restores all 23 canonical themes with icons, sets them `active`, **disables every non-canonical theme**, then creates segments |
| `import_records_from_xlsx:consultation_metadata` | Dry-run by default; `APPLY=1` writes. Creates missing canonical themes with icons (restores soft-deleted ones) and syncs per-consultation theme/segment maps from the export |
| `themes:remap_consultation_themes` | Splits legacy composite theme names onto canonical themes (`find_or_create_theme!` backfills icons + restores soft-deleted) |
| `themes:assign_others_themes` | Hand-mapped fixes for 'Others'-tagged consultations |
| `themes:assign_no_theme_consultations` | Hand-mapped fixes for untagged consultations |

Theme creation in all tasks goes through `Theme.with_deleted` + `restore`, so
re-runs revive a soft-deleted canonical theme instead of inserting a
duplicate-name row. `icon_name ||= icon` backfills only when blank — it never
overwrites an icon set manually in cm-admin.

## Post-deploy runbook

```bash
bundle exec rails db:migrate                                       # adds icon_name + status
bundle exec rails import_records_from_array:themes_and_segments    # seed + disable legacy
bundle exec rails import_records_from_xlsx:consultation_metadata   # dry run, review plan
bundle exec rails import_records_from_xlsx:consultation_metadata APPLY=1
bundle exec rails themes:remap_consultation_themes
bundle exec rails themes:assign_others_themes
bundle exec rails themes:assign_no_theme_consultations
```

The metadata import needs the Excel export at
`imports/consultation_data_updated_2026-10-22.xlsx` (or `FILE=/path/to.xlsx`).

## Gotchas

- `Consultation#set_created_by` (before_validation) overwrites `created_by`
  with `Current.user` — set `Current.user = <user>` before `create!` in
  `rails runner`/`rails console`, or the record saves with a nil creator and
  later publish crashes in `Scorable::Consultation#add_consultation_created_points`.
- Soft-deleted canonical themes are restored by the rake tasks; if you
  genuinely want one gone, delete it after disabling instead.
