# frozen_string_literal: false

module CodePraise
  module Entity
    # Domain entity for team members
    class Member < Dry::Struct
      include Dry::Types.module

      attribute :id,        Integer.optional
      attribute :origin_id, Strict::Integer
      attribute :username,  Strict::String
      attribute :email,     Strict::String.optional
    end
  end
end
