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
GH_URL = 'http://github.com/soumyaray/YPBT-app'

# Helper methods
def homepage
  CodePraise::App.config.APP_HOST
end
