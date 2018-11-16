# frozen_string_literal: true

ENV['RACK_ENV'] = 'app_test'

require 'headless'
require 'watir'
require 'page-object'

require_relative 'spec_helper.rb'
require_relative 'database_helper.rb'
