# frozen_string_literal: true

require 'dry/transaction'

module CodePraise
  module Service
    # Analyzes contributions to a project
    class AppraiseProject
      include Dry::Transaction

      step :validate_project
      step :retrieve_folder_appraisal
      step :reify_appraisal

      private

      def validate_project(input)
        if input[:watched_list].include? input[:requested].project_fullname
          Success(input)
        else
          Failure('Please first request this project to be added to your list')
        end
      end

      def retrieve_folder_appraisal(input)
        result = Gateway::Api.new(CodePraise::App.config)
          .appraise(input[:requested])

        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError
        Failure('Cannot appraise projects right now; please try again later')
      end

      def reify_appraisal(folder_appraisal_json)
        Representer::ProjectFolderContributions.new(OpenStruct.new)
          .from_json(folder_appraisal_json)
          .yield_self { |folder_appraisal| Success(folder_appraisal) }
      rescue StandardError
        Failure('Error in our appraisal report -- please try again')
      end
    end
  end
end
