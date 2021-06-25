source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "6.1.4"

# Use Puma as the app server
gem "puma"
# Use SCSS for stylesheets
gem "sass-rails"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem "coffee-rails"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder"
# Use Redis adapter to run Action Cable in production
# gem 'redis'
# Use ActiveModel has_secure_password
# gem 'bcrypt'

gem "figaro"
gem "gds-api-adapters"
gem "govuk_admin_template"
gem "govuk_frontend_toolkit", git: "https://github.com/alphagov/govuk_frontend_toolkit_gem.git", submodules: true
gem "rainbow"
gem "rest-client"

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Used by healthcheck
gem "logging"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem "capybara"
  gem "json"
  gem "pry"
  gem "rake"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "scss_lint-govuk"
  gem "selenium-webdriver"
  gem "webmock"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "listen"
  gem "web-console"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
