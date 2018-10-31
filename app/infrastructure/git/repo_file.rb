# frozen_string_literal: true

module CodePraise
  module Git
    # Blame output for a single file
    class RepoFile
      attr_reader :filename

      def initialize(filename)
        @filename = filename
      end

      def blame
        @blame ||= CodePraise::Git::Command.new
          .blame(@filename, porcelain: true)
          .call
      end
    end
  end
end
