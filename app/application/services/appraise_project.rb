# frozen_string_literal: true

require 'dry/transaction'

module CodePraise
  module Service
    # Analyzes contributions to a project
    class AppraiseProject
      include Dry::Transaction

      step :validate_project
      step :retrieve_remote_project
      step :clone_remote
      step :appraise_contributions

      private

      def validate_project(input)
        if input[:watched_list].include? input[:requested].project_fullname
          Success(input)
        else
          Failure('Please first request this project to be added to your list')
        end
      end

      def retrieve_remote_project(input)
        input[:project] = Repository::For.klass(Entity::Project).find_full_name(
          input[:requested].owner_name, input[:requested].project_name
        )

        input[:project] ? Success(input) : Failure('Project not found')
      rescue StandardError
        Failure('Having trouble accessing the database')
      end

      def clone_remote(input)
        gitrepo = GitRepo.new(input[:project])
        gitrepo.clone! unless gitrepo.exists_locally?

        Success(input.merge(gitrepo: gitrepo))
      rescue StandardError
        puts error.backtrace.join("\n")
        Failure('Could not clone this project')
      end

      def appraise_contributions(input)
        input[:folder] = Mapper::Contributions
          .new(input[:gitrepo]).for_folder(input[:requested].folder_name)

        Success(input)
      rescue StandardError
        Failure('Could not find that folder')
      end
    end
  end
end
