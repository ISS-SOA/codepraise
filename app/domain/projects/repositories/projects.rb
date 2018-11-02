# frozen_string_literal: true

require_relative 'members'

module CodePraise
  module Repository
    # Repository for Project Entities
    class Projects
      def self.all
        Database::ProjectOrm.all.map { |db_project| rebuild_entity(db_project) }
      end

      def self.find_full_name(owner_name, project_name)
        # SELECT * FROM `projects` LEFT JOIN `members`
        # ON (`members`.`id` = `projects`.`owner_id`)
        # WHERE ((`username` = 'owner_name') AND (`name` = 'project_name'))
        db_project = Database::ProjectOrm
          .left_join(:members, id: :owner_id)
          .where(username: owner_name, name: project_name)
          .first
        rebuild_entity(db_project)
      end

      def self.find(entity)
        find_origin_id(entity.origin_id)
      end

      def self.find_id(id)
        db_record = Database::ProjectOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::ProjectOrm.first(origin_id: origin_id)
        rebuild_entity(db_record)
      end

      def self.create(entity)
        raise 'Project already exists' if find(entity)

        db_project = PersistProject.new(entity).call
        rebuild_entity(db_project)
      end

      private

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Project.new(
          db_record.to_hash.merge(
            owner: Members.rebuild_entity(db_record.owner),
            contributors: Members.rebuild_many(db_record.contributors)
          )
        )
      end

      # Helper class to persist project and its members to database
      class PersistProject
        def initialize(entity)
          @entity = entity
        end

        def create_project
          Database::ProjectOrm.create(@entity.to_attr_hash)
        end

        def call
          owner = Members.db_find_or_create(@entity.owner)

          create_project.tap do |db_project|
            db_project.update(owner: owner)

            @entity.contributors.each do |contributor|
              db_project.add_contributor(Members.db_find_or_create(contributor))
            end
          end
        end
      end
    end
  end
end
