# frozen_string_literal: true

require 'dry/transaction'

module CodePraise
  module Service
    # Transaction to store project from Github API to database
    class AddProject
      include Dry::Transaction

      step :validate_input
      step :find_project
      step :store_project

      private

      def validate_input(input)
        if input.success?
          owner_name, project_name = input[:remote_url].split('/')[-2..-1]
          Success(owner_name: owner_name, project_name: project_name)
        else
          Failure(input.errors.values.join('; '))
        end
      end

      def find_project(input)
        if (project = project_in_database(input))
          input[:local_project] = project
        else
          input[:remote_project] = project_from_github(input)
        end
        Success(input)
      rescue StandardError => error
        Failure(error.to_s)
      end

      def store_project(input)
        project =
          if (new_proj = input[:remote_project])
            Repository::For.entity(new_proj).create(new_proj)
          else
            input[:local_project]
          end
        Success(project)
      rescue StandardError => error
        puts error.backtrace.join("\n")
        Failure('Having trouble accessing the database')
      end

      # following are support methods that other services could use

      def project_from_github(input)
        Github::ProjectMapper
          .new(App.config.GITHUB_TOKEN)
          .find(input[:owner_name], input[:project_name])
      rescue StandardError
        raise 'Could not find that project on Github'
      end

      def project_in_database(input)
        Repository::For.klass(Entity::Project)
          .find_full_name(input[:owner_name], input[:project_name])
      end
    end
  end
end
