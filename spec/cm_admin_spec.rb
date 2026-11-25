require "rails_helper"

RSpec.describe "cm-admin", type: :request do
  it_behaves_like "valid cm_admin model definitions"

  # cm-admin registers models for its own tables (comments, emails, support tickets, bot
  # conversations, translations, ...) but this app only routes the ones in included_models.
  not_enabled = CmAdmin::Testing.models.map(&:name) -
                CmAdmin.config.included_models.map { |model| model.is_a?(String) ? model.classify : model.name }

  it_behaves_like "cm_admin pages render", skip: not_enabled
end
