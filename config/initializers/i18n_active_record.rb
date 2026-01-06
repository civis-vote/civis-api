require 'i18n/backend/active_record'

I18n.backend = I18n::Backend::Chain.new(
  I18n::Backend::ActiveRecord.new, # DB-backed translations (editable at runtime)
  I18n.backend # fallback to the default Simple backend
)

I18n::Backend::ActiveRecord.configure do |config|
  config.cache_translations = true # defaults to false
  # config.cleanup_with_destroy = true # defaults to false
  config.scope = 'cm_admin' # defaults to nil, won't be used
end
