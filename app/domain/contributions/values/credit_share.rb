# frozen_string_literal: true

module CodePraise
  module Value
    # Value of credits shared by contributors for file, files, or folder
    class CreditShare < SimpleDelegator
      # rubocop:disable Style/RedundantSelf
      def initialize
        super(Types::HashedIntegers.new)
      end

      def add_credit(line)
        self[line.contributor] += line.credit
      end

      def +(other)
        (self.contributors + other.contributors).uniq
          .each_with_object(Value::CreditShare.new) do |contributor, total|
            total[contributor] = self[contributor] + other[contributor]
          end
      end

      def by_email(email)
        contributor = self.select { |c, _| c.email == email }.keys.first
        by_contributor(contributor)
      end

      def by_contributor(contributor)
        self[contributor]
      end

      def contributors
        self.keys
      end
      # rubocop:enable Style/RedundantSelf
    end
  end
end
