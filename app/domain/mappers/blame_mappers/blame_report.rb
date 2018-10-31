# frozen_string_literal: true

require 'concurrent'

module CodePraise
  module Praise
    # Git contributions report parsing and reporting services
    class ContributionsReporter
      def initialize(gitrepo)
        @local = gitrepo.local
      end

      def folder_report(folder_name)
        folder_name = '' if folder_name == '/'
        files = @local.files.select { |file| file.start_with? folder_name }
        @local.in_repo do
          files.map do |filename|
            Concurrent::Promise.execute { [filename, file_report(filename)] }
          end.map(&:value)
        end.to_h
      end

      def files(folder_name)
        @local.files.select { |file| file.start_with? folder_name }
      end

      def subfolders(folder_name)
        @local.folder_structure[folder_name]
      end

      def folder_structure
        @local.folder_structure
      end

      def file_report(filename)
        contributions_output = Git::RepoFile.new(filename).blame
        Porcelain.parse_file_blame(contributions_output)
      end
    end
  end
end
