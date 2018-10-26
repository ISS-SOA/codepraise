# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:members) do
      primary_key :id

      Integer     :origin_id, unique: true
      String      :username, unique: true, null: false
      String      :email

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
