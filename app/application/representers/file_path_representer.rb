# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'credit_share_representer'

module CodePraise
  module Representer
    # Represents folder summary about repo's folder
    class FilePath < Roar::Decorator
      include Roar::JSON

      property :directory
      property :filename
    end
  end
end
