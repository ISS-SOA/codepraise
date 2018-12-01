# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module CodePraise
  module Representer
    # Represents essential Member information for API output
    # USAGE:
    #   member = Database::MemberOrm.find(1)
    #   Representer::Member.new(member).to_json
    class Member < Roar::Decorator
      include Roar::JSON

      property :origin_id
      property :username
      property :email
    end
  end
end
