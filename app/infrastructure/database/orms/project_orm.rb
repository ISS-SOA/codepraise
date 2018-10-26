# frozen_string_literal: true

require 'sequel'

module CodePraise
  module Database
    # Object Relational Mapper for Project Entities
    class ProjectOrm < Sequel::Model(:projects)
      many_to_one :owner,
                  class: :'CodePraise::Database::MemberOrm'

      many_to_many :contributors,
                   class: :'CodePraise::Database::MemberOrm',
                   join_table: :projects_members,
                   left_key: :project_id, right_key: :member_id

      plugin :timestamps, update_on_create: true
    end
  end
end
