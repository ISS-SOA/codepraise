# frozen_string_literal: true

module Views
  # View for a single contributor
  class Contributor
    def initialize(contributor)
      @contributor = contributor
    end

    def entity
      @contributor
    end

    def username
      @contributor.username
    end

    def github_profile_url
      "https://github.com/#{@contributor.username}"
    end
  end
end
