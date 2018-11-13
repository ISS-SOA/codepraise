# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'

require 'pry' # for debugging

require_relative '../../init.rb'

USERNAME = 'soumyaray'
PROJECT_NAME = 'YPBT-app'
GITHUB_TOKEN = CodePraise::App.config.GITHUB_TOKEN
CORRECT = YAML.safe_load(File.read('spec/fixtures/gh_results.yml'))

# Helper methods
def homepage
  CodePraise::App.config.APP_HOST
end
