# frozen_string_literal: true

require 'concurrent'

module CodePraise
  module Git
    # Git contributions report parsing and reporting services
    class BlameReporter
      def initialize(gitrepo)
        @local = gitrepo.local
      end

      def folder_report(folder_name)
        folder_name = '' if folder_name == '/'
        files = @local.files.select { |file| file.start_with? folder_name }
        @local.in_repo do
          files.map do |filename|
            [filename, file_report(filename)]
          end
        end
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
        Git::RepoFile.new(filename).blame
      end
    end
  end
end
