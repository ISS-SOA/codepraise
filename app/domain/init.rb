# frozen_string_literal: true

folders = %w[projects contributions views]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
