# frozen_string_literal: true

folders = %w[infrastructure application presentation]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
