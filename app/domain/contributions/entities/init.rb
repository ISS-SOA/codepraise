# frozen_string_literal: true

folders = %w[children root]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
