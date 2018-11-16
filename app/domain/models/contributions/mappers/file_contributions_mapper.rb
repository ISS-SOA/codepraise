# frozen_string_literal: true

module CodePraise
  module Mapper
    # Summarizes a single file's contributions by team members
    class FileContributions
      def initialize(file_report)
        @file_report = file_report
      end

      def build_entity
        Entity::FileContributions.new(
          file_path: filename,
          lines: contributions
        )
      end

      private

      def filename
        @file_report[0]
      end

      def contributions
        summarize_line_reports(@file_report[1])
      end

      def summarize_line_reports(line_reports)
        line_reports.map.with_index do |report, line_index|
          Entity::LineContribution.new(
            contributor: contributor_from(report),
            code: strip_leading_tab(report['code']),
            time: Time.at(report['author-time'].to_i),
            number: index_to_number(line_index)
          )
        end
      end

      def contributor_from(report)
        Entity::Contributor.new(
          username: report['author'],
          email: bare_email(report['author-mail'])
        )
      end

      # remove angle brackets <..> around email addresses
      def bare_email(email)
        email[1..-2]
      end

      # remove leading tab from git blame code output
      def strip_leading_tab(code_line)
        code_line[1..-1]
      end

      # add 1 to line indexes to make them line numbers
      def index_to_number(index)
        index + 1
      end
    end
  end
end
