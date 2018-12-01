# frozen_string_literal: true

folders = %w[view_objects]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
