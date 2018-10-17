# frozen_string_literal: true

require 'pry'

%w[lib]
  .each do |folder|
    require_relative "#{folder}/init.rb"
  end
