# Home Page Showcase Slides GraphQL API

## Overview

A GraphQL query `homePageShowcaseSlides` returns showcase slides for the Home Page from the standalone `ShowcaseSlide` model. The query defaults to **published** status and orders slides by **position ascending** (lowest position number first).

## Query

```graphql
query GetHomePageShowcaseSlides($status: ShowcaseSlideStatuses, $limit: Int) {
  homePageShowcaseSlides(status: $status, limit: $limit) {
    id
    title
    description
    image { url }
    ctaLabel
    ctaUrl
    videoUrl
    status
    position
    publishedAt
  }
}
```

### Arguments

| Argument | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `status` | `ShowcaseSlideStatuses` | No | `published` | Filters slides by status. Exposed so the client can request other statuses if needed. |
| `limit` | `Int` | No | `20` | Maximum number of slides to return. |

### Return type

Returns a list of `ShowcaseSlide` objects (`[ShowcaseSlide]!`).

#### ShowcaseSlide fields

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `Int` | No | ID of the showcase slide |
| `title` | `String` | No | Title of the slide |
| `description` | `String` | Yes | Description text of the slide |
| `image` | `AttachmentType` | Yes | Image for the slide. Accepts an optional `resolution` argument (e.g. `"300x200"`). |
| `ctaLabel` | `String` | No | Label for the call-to-action button |
| `ctaUrl` | `String` | No | URL for the call-to-action button |
| `videoUrl` | `String` | Yes | Video URL for the slide. |
| `status` | `ShowcaseSlideStatuses` | No | Status of the slide (`draft`, `published`, `archived`) |
| `position` | `Int` | Yes | Display order (ascending) |
| `publishedAt` | `DateTime` | Yes | When the slide was published |

## Backend behaviour

The resolver (`Queries::Consultation::HomePageShowcaseSlides`) applies the following filters internally:

1. **Status filter** — defaults to `published`, excluding `draft` and `archived` slides from the Home Page by default.
2. **Ordering** — `position ASC` (lowest position number first).
3. **Limit** — caps the number of results (default 20).

### Key requirement

Draft and archived content does not appear in the Home Page response unless the client explicitly passes a different `status` argument.

## CTA fields

Each `ShowcaseSlide` exposes `ctaLabel` and `ctaUrl` fields for the call-to-action button, backed by the `cta_label` and `cta_url` columns respectively.

## ShowcaseSlide model

The `ShowcaseSlide` is a standalone model with no association to `Consultation`.

### Fields

- `title` (string, required)
- `description` (rich text, required)
- `cta_url` (string, required) — CTA URL
- `video_url` (string) — Video URL
- `cta_label` (string, required) — CTA button label
- `banner_type` (virtual) — `image` or `video`, used by cm-admin to toggle field visibility
- `status` (integer enum: `draft`, `published`, `archived`)
- `position` (integer, required) — display order
- `published_at` (datetime)
- `archived_at` (datetime)
- `image` (ActiveStorage attachment)

### Migration

```ruby
# db/migrate/20260911044844_create_showcase_slides.rb
class CreateShowcaseSlides < ActiveRecord::Migration[8.1]
  def change
    create_table :showcase_slides do |t|
      t.string :title, null: false
      t.string :cta_url, null: false
      t.string :video_url
      t.string :cta_label, null: false
      t.integer :status, default: 0, null: false
      t.integer :position
      t.datetime :published_at
      t.datetime :archived_at
      t.references :created_by, foreign_key: { to_table: :users }, index: true
      t.references :updated_by, foreign_key: { to_table: :users }, index: true

      t.timestamps
    end
  end
end
```

## Files added/modified

### New files

| File | Purpose |
|------|---------|
| `app/models/showcase_slide.rb` | Standalone ShowcaseSlide model |
| `app/models/concerns/cm_admin/showcase_slide.rb` | cm-admin panel for ShowcaseSlide |
| `app/graphql/types/objects/showcase_slide.rb` | GraphQL type for ShowcaseSlide |
| `app/graphql/queries/consultation/home_page_showcase_slides.rb` | Resolver for the `homePageShowcaseSlides` query |
| `db/migrate/20260911044844_create_showcase_slides.rb` | Migration creating `showcase_slides` table |
| `spec/fabricators/showcase_slide_fabricator.rb` | Fabricator for ShowcaseSlide tests |
| `spec/graphql/queries/consultation/home_page_showcase_slides_spec.rb` | RSpec tests |

## Example usage

### Default (published only)

```graphql
query GetHomePageShowcase {
  homePageShowcaseSlides {
    id
    title
    description
    ctaLabel
    ctaUrl
    status
    position
  }
}
```

Response:
```json
{
  "data": {
    "homePageShowcaseSlides": [
      {
        "id": 1,
        "title": "Public Consultation on Urban Planning",
        "description": "Summary of the slide...",
        "ctaLabel": "Have Your Say",
        "ctaUrl": "https://civis.in/consultations/42",
        "status": "published",
        "position": 1
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
query GetDraftSlides {
  homePageShowcaseSlides(status: draft) {
    id
    title
    status
  }
}
```
