# frozen_string_literal: true

module CodePraise
  # Provides access to contributor data
  module Github
    # Data Mapper: Github contributor -> Member entity
    class MemberMapper
      def initialize(gh_token, gateway_class = Github::Api)
        @token = gh_token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@token)
      end

      def load_several(url)
        @gateway.contributors_data(url).map do |data|
          MemberMapper.build_entity(data)
        end
      end

      def self.build_entity(data)
        DataMapper.new(data).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          Entity::Member.new(
            id: nil,
            origin_id: origin_id,
            username: username,
            email: email
          )
        end

        private

        def origin_id
          @data['id']
        end

        def username
          @data['login']
        end

        def email
          @data['email']
        end
      end
    end
  end
end
