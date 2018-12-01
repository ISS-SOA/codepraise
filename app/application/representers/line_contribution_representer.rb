# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'contributor_representer'

module CodePraise
  module Representer
    # Represents folder summary about repo's folder
    class LineContribution < Roar::Decorator
      include Roar::JSON

      property :contributor, extend: Representer::Contributor, class: OpenStruct
      property :code
      property :time
      property :number
      property :credit
      property :useless?
    end
  end
end
