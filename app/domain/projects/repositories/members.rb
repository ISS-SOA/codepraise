# frozen_string_literal: true

module CodePraise
  module Repository
    # Repository for Members
    class Members
      def self.find_id(id)
        rebuild_entity Database::MemberOrm.first(id: id)
      end

      def self.find_username(username)
        rebuild_entity Database::MemberOrm.first(username: username)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Member.new(
          id: db_record.id,
          origin_id: db_record.origin_id,
          username: db_record.username,
          email: db_record.email
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_member|
          Members.rebuild_entity(db_member)
        end
      end

      def self.find_or_create(entity)
        Database::MemberOrm.find_or_create(entity.to_attr_hash)
      end
    end
  end
end
