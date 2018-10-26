# frozen_string_literal: false

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'

require 'pry' # for debugging

require_relative '../init.rb'

USERNAME = 'soumyaray'.freeze
PROJECT_NAME = 'YPBT-app'.freeze
GITHUB_TOKEN = CodePraise::App.config.GITHUB_TOKEN
CORRECT = YAML.safe_load(File.read('spec/fixtures/gh_results.yml'))
