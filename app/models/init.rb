# frozen_string_literal: true

folders = %w[entities gateways mappers]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
