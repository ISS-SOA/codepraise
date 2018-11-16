# frozen_string_literal: true

Dir.glob("#{File.dirname(__FILE__)}/*.rb").each do |file|
  require file
end
