# frozen_string_literal: true

module CodePraise
  module Value
    # Value of a file's full path (delegates to String)
    class FilePath < SimpleDelegator
      # rubocop:disable Style/RedundantSelf
      FILE_PATH_REGEX = %r{(?<directory>.*\/)(?<filename>[^\/]+)}.freeze

      attr_reader :directory, :filename

      def initialize(filepath)
        super(filepath)
        parse_path
      end

      def folder_after(root)
        raise(ArgumentError, 'Path mismatch') unless
          self.start_with?(root) || root.empty?

        matches = self.match(%r{(?<folder>^#{root}[^\/]+)[\/]?})
        matches[:folder]
      end

      def parse_path
        return if @names

        @names = self.match(FILE_PATH_REGEX)
        @directory = @names ? @names[:directory] : ''
        @filename = @names ? @names[:filename] : self
      end
      # rubocop:enable Style/RedundantSelf
    end
  end
end
