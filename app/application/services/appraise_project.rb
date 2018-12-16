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
        input[:response] = Gateway::Api.new(CodePraise::App.config)
          .appraise(input[:requested])

        input[:response].success? ? Success(input) : Failure(response.message)
      rescue StandardError
        Failure('Cannot appraise projects right now; please try again later')
      end

      def reify_appraisal(input)
        unless input[:response].processing?
          Representer::ProjectFolderContributions.new(OpenStruct.new)
            .from_json(input[:response].payload)
            .yield_self { |report| input[:appraised] = report }
        end

        Success(input)
      rescue StandardError
        Failure('Error in our appraisal report -- please try again')
      end
    end
  end
end
