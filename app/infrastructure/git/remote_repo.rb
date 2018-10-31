# frozen_string_literal: true

require 'base64'

module CodePraise
  module Git
    # USAGE:
    #   load 'infrastructure/gitrepo/gitrepo.rb'
    #   origin = Git::RemoteGitRepo.new('git@github.com:soumyaray/YPBT-app.git')
    #   local = Git::LocalGitRepo.new(origin, 'infrastructure/gitrepo/repostore')

    # Manage remote Git repository for cloning
    class RemoteGitRepo
      attr_reader :git_url

      def initialize(git_url)
        @git_url = git_url
      end

      def unique_id
        Base64.urlsafe_encode64(Digest::SHA256.digest(@git_url))
      end

      def local_clone(path)
        CodePraise::Git::Command.new
          .clone(git_url, path)
          .with_std_error
          .with_progress
          .capture_call { |line| yield line }
      end
    end
  end
end
