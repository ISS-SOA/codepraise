# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'member_representer'

# Represents essential Repo information for API output
module CodePraise
  module Representer
    # Represent a Project entity as Json
    class Project < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :origin_id
      property :name
      property :ssh_url
      property :fullname
      property :owner, extend: Representer::Member, class: OpenStruct
      collection :contributors, extend: Representer::Member, class: OpenStruct

      link :self do
        "api/v1/projects/#{project_name}/#{owner_name}"
      end

      private

      def project_name
        represented.name
      end

      def owner_name
        represented.owner.username
      end
    end
  end
end
