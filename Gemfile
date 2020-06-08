source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.3"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0.0.rc1"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 3.12"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 4.0"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
gem "redis"
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem "kaminari"

gem "rack-cors"

gem "postmark-rails"

gem "devise"

gem "graphql"
gem "graphql-errors"

gem "rollbar"

gem "sidekiq"

gem "simple_form"

gem "local_time", "~> 2.1"

gem "travis"

gem "whenever", require: false

gem "roo", "~> 2.8.0"

gem "sitemap_generator"

gem "aws-sdk-s3", require: false

gem 'rails-erd'
# Use Active Storage variant
gem "image_processing"
gem "mini_magick"
gem "google-cloud-storage"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

gem "spotlight_search", "~> 0.1.7"

gem "slim-rails"
# oauth gems
gem "omniauth"
gem "omniauth-google-oauth2"
gem "omniauth-linkedin-oauth2"
gem "omniauth-facebook"
gem "shrine", "~> 3.0"
gem "cocoon"
gem 'react-rails', '~> 2.6.0'
gem 'cm_page_builder-rails'

group :development, :test, :staging do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "fabrication"
  gem "faker"
  gem "database_cleaner"
  gem "better_errors"
  gem "binding_of_caller"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "rspec-rails", "~> 3.7"
  gem "rb-readline"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-performance", require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers"
  gem "rspec-rails", "~> 3.7"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "graphiql-rails", group: :development
