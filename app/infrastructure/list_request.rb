# frozen_string_literal: true

require 'base64'
require 'dry/monads/result'
require 'json'

module CodePraise
  module Gateway
    module Value
      # List request parser
      class ListRequest
        include Dry::Monads::Result::Mixin

        # Use in client App to create params to send
        def self.to_encoded(list)
          Base64.urlsafe_encode64(list.to_json)
        end

        # Use in tests to create a ListRequest object from a list
        def self.to_request(list)
          ListRequest.new('list' => to_encoded(list))
        end
      end
    end
  end
end
