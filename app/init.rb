# frozen_string_literal: true

folders = %w[domain infrastructure application]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
