# frozen_string_literal: true

require 'sequel'

module CodePraise
  module Database
    # Object-Relational Mapper for Members
    class MemberOrm < Sequel::Model(:members)
      one_to_many :owned_projects,
                  class: :'CodePraise::Database::ProjectOrm',
                  key: :owner_id

      many_to_many :contributed_projects,
                   class: :'CodePraise::Database::ProjectOrm',
                   join_table: :projects_members,
                   left_key: :member_id, right_key: :project_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(member_info)
        first(username: member_info[:username]) || create(member_info)
      end
    end
  end
end
