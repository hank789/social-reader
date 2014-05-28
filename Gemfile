source 'http://ruby.taobao.org'

def darwin_only(require_as)
  RUBY_PLATFORM.include?('darwin') && require_as
end

def linux_only(require_as)
  RUBY_PLATFORM.include?('linux') && require_as
end

gem "rails", "~> 4.0.0"

gem "protected_attributes"
gem 'rails-observers'

# Default values for AR models
gem "default_value_for", "~> 3.0.0"

# Supported DBs
gem "mysql2", '~> 0.3.15', group: :mysql
# gem "pg", group: :postgres

# Auth
gem "devise", '3.0.4'
gem "devise-async", '0.8.0'
gem 'omniauth', "~> 1.2.1"
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'
gem 'omniauth-github'
gem 'omniauth-facebook', '~> 1.6.0'
gem 'omniauth-instagram', '~> 1.0.1'

# Extracting information from a git repository

# LDAP Auth
gem 'gitlab_omniauth-ldap', '1.0.4', require: "omniauth-ldap"

# Language detection
gem "gitlab-linguist", "~> 3.0.0", require: "linguist"

# API
gem "grape", "~> 0.7.0"
# Replace with rubygems when nesteted entities get released
gem "grape-entity", "~> 0.4.2"
gem 'rack-cors', require: 'rack/cors'

# Email validation
gem "email_validator", "~> 1.4.0", :require => 'email_validator/strict'

# Format dates and times
# based on human-friendly examples
gem "stamp"

# Enumeration fields
gem 'enumerize'

# Pagination
gem "kaminari", "~> 0.15.1"

# HAML
gem "haml-rails"

# Files attachments
gem "carrierwave"

# for aws storage
gem "fog", "~> 1.14", group: :aws
gem "unf", group: :aws

# Authorization
gem "six"

# Seed data
gem "seed-fu"

# Markdown to HTML
gem "redcarpet",     "~> 2.2.2"
gem "github-markup"

# Diffs
# gem 'diffy', '~> 3.0.3'

# Asciidoc to HTML
gem  "asciidoctor"

# Application server
group :unicorn do
  gem "unicorn", '~> 4.6.3'
  gem 'unicorn-worker-killer'
end

# State machine
gem "state_machine"

# Post tags
gem "acts-as-taggable-on", '~> 3.2.1'

# Background jobs
gem 'slim'
gem 'sinatra', require: nil
gem 'sidekiq', '~> 3.0.2'

# HTTP requests
gem "httparty"

# Colored output to console
gem "colored"

# GitLab settings
gem 'settingslogic'

# Misc
gem "foreman"
gem 'version_sorter'

# Cache
gem "redis-rails"

# Campfire integration
# gem 'tinder', '~> 1.9.2'

# HipChat integration
gem "hipchat", "~> 0.14.0"

# Gemnasium integration
gem "gemnasium-gitlab-service", "~> 0.2"

# Slack integration
gem "slack-notifier", "~> 0.3.2"

# d3
gem "d3_rails", "~> 3.1.4"

# underscore-rails
gem "underscore-rails", "~> 1.4.4"

# Sanitize user input
gem "sanitize", '~> 2.0'

# Protect against bruteforcing
gem "rack-attack"

# Ace editor
gem 'ace-rails-ap'

gem "sass-rails", '~> 4.0.2'
gem "coffee-rails"
gem "uglifier"
gem "therubyracer"
gem 'turbolinks'
gem 'jquery-turbolinks'

gem 'select2-rails'
gem 'jquery-atwho-rails', "~> 0.3.3"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "raphael-rails", "~> 2.1.2"
gem 'bootstrap-sass', '~> 3.0'
gem "font-awesome-rails", '~> 3.2'
gem "gitlab_emoji", "~> 0.0.1.1"
gem "gon", '~> 5.0.0'
gem 'nprogress-rails'


# service
gem 'twitter', '~> 5.8.0'
gem "koala", "~> 1.10.0rc"
gem 'instagram', '~> 1.0.0'

# rss
gem "feedbag", "~> 0.9.2"
gem "feedjira", "~> 1.3.0"

group :development do
  gem "annotate", "~> 2.6.0.beta2"
  gem "letter_opener"
  gem 'quiet_assets', '~> 1.0.1'
  gem 'rack-mini-profiler', require: false

  # Better errors handler
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'rails_best_practices'

  # Docs generator
  gem "sdoc"

  # thin instead webrick
  gem 'thin'
end

group :development, :test do
  gem 'coveralls', require: false
  # gem 'rails-dev-tweaks'
  gem 'spinach-rails'
  gem "rspec-rails"
  gem "capybara"
  gem "pry"
  gem "awesome_print"
  gem "database_cleaner"
  gem "launchy"
  gem 'factory_girl_rails'

  # Prevent occasions where minitest is not bundled in packaged versions of ruby (see #3826)
  gem 'minitest', '~> 4.7.0'

  # Generate Fake data
  gem "ffaker"

  # Guard
  gem 'guard-rspec'
  gem 'guard-spinach'

  # Notification
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'growl',      require: darwin_only('growl')
  gem 'rb-inotify', require: linux_only('rb-inotify')

  # PhantomJS driver for Capybara
  gem 'poltergeist', '~> 1.4.1'

  gem 'jasmine', '2.0.0.rc5'

  gem "spring", '1.1.1'
  gem "spring-commands-rspec", '1.0.1'
  gem "spring-commands-spinach", '1.0.0'
end

group :test do
  gem "simplecov", require: false
  gem "shoulda-matchers", "~> 2.1.0"
  gem 'email_spec'
  gem "webmock"
  gem 'test_after_commit'
end

group :production do
  gem "gitlab_meta", '6.0'
end
