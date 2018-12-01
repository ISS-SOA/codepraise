# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.5.3'

# PRESENTATION LAYER
gem 'slim', '~> 3.0'

# APPLICATION LAYER
# Web application related
gem 'econfig', '~> 2.1'
gem 'puma', '~> 3.11'
gem 'roda', '~> 3.8'

# Controllers and services
gem 'dry-monads'
gem 'dry-transaction'
gem 'dry-validation'

# Representers
gem 'multi_json'
gem 'roar'

# INFRASTRUCTURE LAYER
# Networking
gem 'http', '~> 3.0'

# DEBUGGING
group :development, :test do
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end

# TESTING
group :test do
  gem 'headless', '~> 2.3'
  gem 'minitest', '~> 5.11'
  gem 'minitest-rg', '~> 5.2'
  gem 'page-object'
  gem 'simplecov', '~> 0.16'
  gem 'vcr', '~> 4.0'
  gem 'watir', '~> 6.14'
  gem 'webmock', '~> 3.4'
end

# QUALITY
group :development, :test do
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end

# UTILITIES
gem 'pry'
gem 'rake', '~> 12.3'

group :development, :test do
  gem 'rerun'
end
