# frozen_string_literal: true

folders = %w[orms]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
