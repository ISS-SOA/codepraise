# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.5.3'

# Web application related
gem 'econfig', '~> 2.1'
gem 'puma', '~> 3.11'
gem 'roda', '~> 3.8'
gem 'slim', '~> 3.0'

# Entity gems
gem 'dry-struct', '~> 0.5'
gem 'dry-types', '~> 0.5'

# Networking
gem 'http', '~> 3.0'

# Database related
gem 'hirb', '~> 0.7'
gem 'sequel', '~> 5.13'

group :development, :test do
  gem 'database_cleaner'
  gem 'sqlite3'
end

group :production do
  gem 'pg', '~> 0.18'
end

# Debugging
gem 'debase'
gem 'pry'
gem 'ruby-debug-ide'

# Testing
group :test do
  gem 'headless', '~> 2.3'
  gem 'minitest', '~> 5.11'
  gem 'minitest-rg', '~> 5.2'
  gem 'simplecov', '~> 0.16'
  gem 'vcr', '~> 4.0'
  gem 'watir', '~> 6.14'
  gem 'webmock', '~> 3.4'
end

# Quality
group :development, :test do
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end

# Utilities
gem 'rake', '~> 12.3'

group :development, :test do
  gem 'rerun'
end
