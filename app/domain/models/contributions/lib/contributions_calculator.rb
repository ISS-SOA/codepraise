# frozen_string_literal: true

module CodePraise
  module Mixins
    # line credit calculation methods
    module ContributionsCalculator
      def line_count
        lines.map(&:credit).sum
      end

      def lines_by(contributor)
        lines.select { |line| line.contributor == contributor }
      end

      def total_credits
        lines.map(&:credit).sum
      end

      def credits_for(contributor)
        lines_by(contributor).map(&:credit).sum
      end

      def percent_credit_of(contributor)
        ((credits_for(contributor).to_f / line_count) * 100).round
      end
    end
  end
end
