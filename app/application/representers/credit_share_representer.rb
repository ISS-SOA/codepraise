# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'contributor_representer'

module CodePraise
  module Representer
    # Represents a CreditShare value
    class CreditShare < Roar::Decorator
      include Roar::JSON

      property :share
      collection :contributors, extend: Representer::Contributor,
                                class: OpenStruct
    end
  end
end
