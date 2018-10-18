# frozen_string_literal: false

require 'http'

module CodePraise
  module Github
    # Library for Github Web API
    class Api
      def initialize(token)
        @gh_token = token
      end

      def repo_data(username, project_name)
        Request.new(@gh_token).repo(username, project_name).parse
      end

      def contributors_data(contributors_url)
        Request.new(@gh_token).get(contributors_url).parse
      end

      # Sends out HTTP requests to Github
      class Request
        REPOS_PATH = 'https://api.github.com/repos/'.freeze

        def initialize(token)
          @token = token
        end

        def repo(username, project_name)
          get(REPOS_PATH + [username, project_name].join('/'))
        end

        def get(url)
          http_response = HTTP.headers(
            'Accept' => 'application/vnd.github.v3+json',
            'Authorization' => "token #{@token}"
          ).get(url)

          Response.new(http_response).tap do |response|
            raise(response.error) unless response.successful?
          end
        end
      end

      # Decorates HTTP responses from Github with success/error
      class Response < SimpleDelegator
        Unauthorized = Class.new(StandardError)
        NotFound = Class.new(StandardError)

        HTTP_ERROR = {
          401 => Unauthorized,
          404 => NotFound
        }.freeze

        def successful?
          HTTP_ERROR.keys.include?(code) ? false : true
        end

        def error
          HTTP_ERROR[code]
        end
      end
    end
  end
end
