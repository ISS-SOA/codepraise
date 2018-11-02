# frozen_string_literal: true

folders = %w[lib children root]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
