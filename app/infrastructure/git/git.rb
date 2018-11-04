# frozen_string_literal: true

module CodePraise
  module Git
    # Basic gateway to git shell commands
    class Command
      GIT = 'git'

      def initialize
        @command = []
        @options = []
        @params = []
        @redirects = []
      end

      def clone(git_url, path)
        @command = 'clone'
        @params = [git_url, path]
        self
      end

      def blame(filename, porcelain: true)
        @command = 'blame'
        @options << 'line-porcelain' if porcelain
        @params = filename
        self
      end

      def with_progress
        @options << 'progress'
        self
      end

      def with_std_error
        @redirects << '2>&1'
        self
      end

      def options
        @options.map { |option| '--' + option }
      end

      def full_command
        [GIT, @command, options, @params, @redirects]
          .compact
          .flatten
          .join(' ')
      end

      def call
        `#{full_command}`
      end

      def capture_call
        IO.popen(full_command).each do |line|
          yield line if block_given?
        end
      end
    end
  end
end
