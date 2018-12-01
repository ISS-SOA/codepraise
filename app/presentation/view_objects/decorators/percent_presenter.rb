# frozen_string_literal: true

module Views
  # Calculates percentage numbers
  module PercentPresenter
    def self.call(num1, num2)
      ((num1.to_f / num2) * 100).round
    rescue FloatDomainError
      Float(0)
    end
  end
end
