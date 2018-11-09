# frozen_string_literal: true

require 'concurrent'

module CodePraise
  module Git
    # Git contributions report parsing and reporting services
    class BlameReporter
      NOT_FOUND_ERROR_MSG = 'Folder not found'

      def initialize(gitrepo)
        @local = gitrepo.local
      end

      def folder_report(folder_name)
        folder_name = '' if ['/', ''].include? folder_name
        raise not_found_error(folder_name) unless folder_exists?(folder_name)

        fnames = @local.files.select { |file| file.start_with? folder_name }
        @local.in_repo { fnames.map { |fname| [fname, file_report(fname)] } }
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

      private

      def folder_exists?(folder_name)
        return true if folder_name.empty?

        @local.in_repo { Dir.exist? folder_name }
      end

      def not_found_error(folder_name)
        "#{NOT_FOUND_ERROR_MSG} (#{folder_name})"
      end
    end
  end
end
