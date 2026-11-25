# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
# Uncomment the line below in case you have `--require rails_helper` in the `.rspec` file
# that will avoid rails generators crashing because migrations haven't been run yet
# return unless Rails.env.test?
require 'rspec/rails'
# cm-admin helpers and matchers for every request spec. Build its CSS first: bin/rails test:prepare.
require 'cm_admin/testing/rspec'
require 'fabrication'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
# Mirror the app's Authentication concern: admin requests run with Current.user set to the
# signed-in user, and several models stamp created_by and points from it while records are built.
# Included below, after the gem's own configure block, so this cm_admin_sign_in takes precedence.
module CmAdminCurrentUserExtension
  def cm_admin_sign_in(*args, **options)
    user = super
    Current.user = user
    user
  end
end

RSpec.configure do |config|
  # Use the test queue adapter so jobs are enqueued but not executed (avoids Redis dependency)
  ActiveJob::Base.queue_adapter = :test

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # Trackable models stamp created_by_id/updated_by_id from Current.user;
  # reset it so a rolled-back user's id cannot leak into the next example.
  config.before { Current.reset }

  # Scorable concerns record point events on user and response creation, and look the
  # points up in PointScale — the rows the point_scale.csv seed provides in development.
  config.before(:suite) do
    PointScale.actions.keys.each do |action|
      PointScale.find_or_create_by!(action:, upper_limit: 1_000_000) { |scale| scale.points = 1.0 }
    end
  end

  # Sidekiq::Cron registers schedules in Redis, which the test suite does not run.
  # CmCronJob#schedule_job fires on every save, so stub the registry instead of needing
  # a Redis connection in CI.
  config.before(:suite) do
    Sidekiq::Cron::Job.singleton_class.class_eval do
      def find(_name) = nil
      def create(*) = true
    end
  end

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails uses metadata to mix in different behaviours to your tests,
  # for example enabling you to call `get` and `post` in request specs. e.g.:
  #
  #     RSpec.describe UsersController, type: :request do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/7-1/rspec-rails
  #
  # You can also this infer these behaviours automatically by location, e.g.
  # /spec/models would pull in the same behaviour as `type: :model` but this
  # behaviour is considered legacy and will be removed in a future version.
  #
  # To enable this behaviour uncomment the line below.
  # config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include FactoryBot::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers
  config.include GraphqlRequestHelpers, type: :request
  config.include GraphqlSchemaHelpers, type: :graphql

  config.include CmAdminCurrentUserExtension, type: :request
end
