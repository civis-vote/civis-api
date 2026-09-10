# Home Page Showcase Slides GraphQL API

## Overview

A new GraphQL query `homePageShowcaseSlides` exposes Consultations as showcase slides for the Home Page. The query returns only **public** consultations, defaults to **published** status, and orders slides by **response_deadline ascending** (soonest deadline first).

## Query

```graphql
query GetHomePageShowcaseSlides($status: ConsultationStatuses, $limit: Int) {
  homePageShowcaseSlides(status: $status, limit: $limit) {
    id
    title
    description
    image { url }
    cta { label url }
    status
    responseDeadline
    publishedAt
  }
}
```

### Arguments

| Argument | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `status` | `ConsultationStatuses` | No | `published` | Filters consultations by status. Exposed so the client can request other statuses if needed. |
| `limit` | `Int` | No | `20` | Maximum number of slides to return. |

### Return type

Returns a list of `ShowcaseSlide` objects (`[ShowcaseSlide]!`).

#### ShowcaseSlide fields

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `Int` | No | ID of the consultation |
| `title` | `String` | No | Title of the consultation |
| `description` | `String` | Yes | English summary text of the consultation |
| `image` | `AttachmentType` | Yes | Consultation logo image. Accepts an optional `resolution` argument (e.g. `"300x200"`). |
| `cta` | `ShowcaseSlideCta` | Yes | Call-to-action. `null` when the consultation has no `url`. |
| `status` | `ConsultationStatuses` | No | Status of the consultation (`submitted`, `published`, `rejected`, `expired`) |
| `responseDeadline` | `DateTime` | Yes | Response deadline (used for ordering) |
| `publishedAt` | `DateTime` | Yes | When the consultation was published |

#### ShowcaseSlideCta fields

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `label` | `String` | No | CTA button label. Uses the consultation's `cta_label` column if set; falls back to `"Participate"`. |
| `url` | `String` | No | The consultation's `url` |

## Backend behaviour

The resolver (`Queries::Consultation::HomePageShowcaseSlides`) applies the following filters internally:

1. **Public consultations only** — uses the `public_consultation` scope to exclude private consultations.
2. **Status filter** — defaults to `published`, excluding `submitted`, `rejected`, and `expired` consultations from the Home Page by default.
3. **Non-null response_deadline** — consultations without a `response_deadline` are excluded.
4. **Ordering** — `response_deadline ASC` (soonest deadline first).
5. **Limit** — caps the number of results (default 20).

### Key requirement

Draft (`submitted`) and archived (`expired`/`rejected`) content does not appear in the Home Page response unless the client explicitly passes a different `status` argument.

## CTA label field

A new `cta_label` string column was added to the `consultations` table, allowing each consultation to specify a custom CTA button label for the Home Page showcase.

- When `cta_label` is set on a consultation, it is used as the CTA label.
- When `cta_label` is blank/nil, the label defaults to `"Participate"`.
- The CTA object is `null` entirely when the consultation has no `url`.

### Migration

```ruby
# db/migrate/20260910111505_add_cta_label_to_consultations.rb
class AddCtaLabelToConsultations < ActiveRecord::Migration[8.1]
  def change
    add_column :consultations, :cta_label, :string
  end
end
```

## Files added/modified

### New files

| File | Purpose |
|------|---------|
| `app/graphql/types/objects/showcase_slide_cta.rb` | GraphQL type for the CTA (`label`, `url`) |
| `app/graphql/types/objects/showcase_slide.rb` | GraphQL type wrapping Consultation with Home Page fields |
| `app/graphql/queries/consultation/home_page_showcase_slides.rb` | Resolver for the `homePageShowcaseSlides` query |
| `db/migrate/20260910111505_add_cta_label_to_consultations.rb` | Migration adding `cta_label` column |
| `spec/graphql/queries/consultation/home_page_showcase_slides_spec.rb` | RSpec tests (12 examples) |
| `spec/fabricators/department_fabricator.rb` | Department fabricator for tests |
| `spec/fabricators/department_contact_fabricator.rb` | DepartmentContact fabricator for tests |

### Modified files

| File | Change |
|------|--------|
| `app/graphql/types/query_type.rb` | Registered `home_page_showcase_slides` field |
| `spec/fabricators/consultation_fabricator.rb` | Fixed outdated `ministry_id`/`Ministry` references to `department`/`Department` |
| `config/storage.yml` | Fixed pre-existing bug: `.dump` on nil in commented-out ERB lines |
| `spec/rails_helper.rb` | Added fabrication require and test queue adapter config |

## Test coverage

The spec file contains 12 tests covering:

1. Published slides are returned by default
2. Submitted (draft) slides are not returned
3. Expired slides are not returned
4. Rejected slides are not returned
5. Multiple published slides returned in correct order (response_deadline asc)
6. Empty list when no published consultations exist
7. All required Home Page fields are present in the response
8. Custom `cta_label` is used when set
9. Falls back to `"Participate"` when `cta_label` is not set
10. CTA is null when consultation has no URL
11. Private consultations are excluded
12. Status filtering works when a different status is passed
13. Limit argument constrains the number of results

## Example usage

### Default (published only)

```graphql
query GetHomePageShowcase {
  homePageShowcaseSlides {
    id
    title
    description
    cta { label url }
    status
    responseDeadline
  }
}
```

Response:
```json
{
  "data": {
    "homePageShowcaseSlides": [
      {
        "id": 42,
        "title": "Public Consultation on Urban Planning",
        "description": "Summary of the consultation...",
        "cta": { "label": "Have Your Say", "url": "https://civis.in/consultations/42" },
        "status": "published",
        "responseDeadline": "2026-09-20T18:30:00Z"
      }
    ]
  }
}
```

### With limit

```graphql
query GetHomePageShowcase {
  homePageShowcaseSlides(limit: 5) {
    id
    title
  }
}
```

### With explicit status

```graphql
query GetSubmittedConsultations {
  homePageShowcaseSlides(status: submitted) {
    id
    title
    status
  }
}
```
