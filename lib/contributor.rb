# frozen_string_literal: false

module CodePraise
  # Provides access to contributor data
  class Contributor
    def initialize(contributor_data)
      @contributor = contributor_data
    end

    def username
      @contributor['login']
    end

    def email
      @contributor['email']
    end
  end
end
