# frozen_string_literal: false

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'
require 'pry' # for debugging

require_relative '../init.rb'

USERNAME = 'soumyaray'.freeze
PROJECT_NAME = 'YPBT-app'.freeze
CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
GH_TOKEN = CONFIG['GH_TOKEN']
CORRECT = YAML.safe_load(File.read('spec/fixtures/gh_results.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'.freeze
CASSETTE_FILE = 'github_api'.freeze
