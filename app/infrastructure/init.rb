# frozen_string_literal: true

folders = %w[github database git]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
