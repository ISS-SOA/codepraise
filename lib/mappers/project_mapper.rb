# frozen_string_literal: false

require_relative 'member_mapper.rb'

module CodePraise
  module Github
    # Data Mapper: Github repo -> Project entity
    class ProjectMapper
      def initialize(gh_token, gateway_class = Github::Api)
        @token = gh_token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@token)
      end

      def find(owner_name, project_name)
        data = @gateway.repo_data(owner_name, project_name)
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data, @token, @gateway_class).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, token, gateway_class)
          @data = data
          @member_mapper = MemberMapper.new(
            token, gateway_class
          )
        end

        def build_entity
          CodePraise::Entity::Project.new(
            id: nil,
            origin_id: origin_id,
            name: name,
            size: size,
            git_url: git_url,
            owner: owner,
            members: members
          )
        end

        def origin_id
          @data['id']
        end

        def name
          @data['name']
        end

        def size
          @data['size']
        end

        def owner
          MemberMapper.build_entity(@data['owner'])
        end

        def git_url
          @data['git_url']
        end

        def members
          @member_mapper.load_several(@data['contributors_url'])
        end
      end
    end
  end
end
