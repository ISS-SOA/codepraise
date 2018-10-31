# frozen_string_literal: true

module CodePraise
  module Entity
    # Summarizes a single file's contributions by team members
    class FileContributions
      def initialize(file_report)
        @file_report = file_report
      end

      def filename
        @file_report[0]
      end

      def contributions
        @contributions ||= summarize_line_reports(@file_report[1])
      end

      private

      def summarize_line_reports(line_reports)
        line_reports.each_with_object({}) do |report, contributions|
          contributions[report['author-mail']] ||= { count: 0 }
          contributions[report['author-mail']][:name] ||= report['author']
          contributions[report['author-mail']][:count] += 1
        end
      end
    end
  end
end
