# frozen_string_literal: true

folders = %w[gateways database]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
