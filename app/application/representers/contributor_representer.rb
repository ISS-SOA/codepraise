# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module CodePraise
  module Representer
    # Represents a CreditShare value
    class Contributor < Roar::Decorator
      include Roar::JSON

      property :username
      property :email
    end
  end
end
