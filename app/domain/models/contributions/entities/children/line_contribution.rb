# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require_relative 'contributor'

module CodePraise
  module Entity
    # Entity for a single line of code contributed by a team-member
    class LineContribution < Dry::Struct
      COMMENT = '[#\/]'
      WHITESPACE = '[ \t]'
      LINE_END = '$'
      RUBY_USELESS = /^#{WHITESPACE}*(#{COMMENT}|#{LINE_END})/.freeze
      NO_CREDIT = 0
      FULL_CREDIT = 1

      include Dry::Types.module

      attribute :contributor,  Contributor
      attribute :code,         Strict::String
      attribute :time,         Strict::Time
      attribute :number,       Coercible::Integer

      def credit
        useless? ? NO_CREDIT : FULL_CREDIT
      end

      def useless?
        code.match(RUBY_USELESS)
      end
    end
  end
end
