# frozen_string_literal: true

module CodePraise
  module Praise
    # Git contributions parsing and reporting services
    class Contributions
      def initialize(gitrepo)
        @gitrepo = gitrepo
      end

      def for_folder(folder_name)
        contributions_reports = Praise::ContributionsReporter.new(@gitrepo).folder_report(folder_name)
        Entity::FolderContributions.new(folder_name, contributions_reports)
      end
    end
  end
end
