# frozen_string_literal: true

folders = %w[projects contributions]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
