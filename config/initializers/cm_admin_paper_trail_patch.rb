# cm-admin 8.2.8 ships a PaperTrailDefaultConfig module (config/initializers/papertrail.rb)
# whose has_paper_trail(options = {}) calls super with a positional Hash, but the gem's own
# ActiveRecord::Base.has_paper_trail wrapper (lib/cm_admin.rb) accepts kwargs only (**options),
# which raises ArgumentError. Reopening the module here to forward keywords correctly.
if defined?(PaperTrailDefaultConfig)
  module PaperTrailDefaultConfig
    # rubocop:disable Naming/PredicateName
    def has_paper_trail(*args, **options)
      options = args.first.merge(options) if args.first.is_a?(Hash)
      super(**options.merge(ignore: Array(options[:ignore]) | %i[created_at updated_at]))
    end
    # rubocop:enable Naming/PredicateName
  end
end
