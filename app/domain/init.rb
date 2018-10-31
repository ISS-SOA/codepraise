# frozen_string_literal: true

folders = %w[entities mappers repositories]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
