# frozen_string_literal: true

require_relative 'file_contributions_mapper'

module CodePraise
  module Mapper
    # Summarizes contributions for an entire folder
    class FolderContributions
      attr_reader :folder_name
      attr_reader :contributions_reports

      def initialize(folder_name, contributions_reports)
        @folder_name = folder_name
        @contributions_reports = contributions_reports
      end

      def build_entity
        Entity::FolderContributions.new(
          path: @folder_name,
          files: file_summaries
        )
      end

      def file_summaries
        @contributions_reports.map do |file_report|
          Mapper::FileContributions.new(file_report).build_entity
        end
      end

      # defunct below

      def subfolders
        structured = file_summaries.each_with_object({}) do |summary, folders|
          (folders[rel_path(summary.filename)] ||= []) << summary.contributions
        end

        structured.map do |folder, folder_summaries|
          [folder, add_contributions(folder_summaries)]
        end.to_h
      end

      def base_files
        file_summaries
          .select { |file, _| base_level_file?(file) }
          .map { |file, summary| [filename_only(file), summary.contributions] }
          .to_h
      end

      private

      def base_level_file?(filename)
        rel_path(filename).empty?
      end

      def add_contributions(summaries)
        summaries.each_with_object({}) do |summary, contributions|
          summary.contributions.each do |contribution|
            email = contribution[0]
            contributions[email] ||= { name: contribution[1][:name], count: 0 }
            contributions[email][:count] += contribution[1][:count]
          end
        end
      end

      def folder_prefix_length
        @folder_prefix_length ||=
          folder_name.length.zero? ? 0 : folder_name.length + 1
      end

      def rel_path(filename)
        rel_filename = filename[(folder_prefix_length)..-1]
        match = rel_filename.match(%r{(?<folder>[^\/]+)\/.*})
        match.nil? ? '' : match[:folder]
      end

      def filename_only(filename)
        rel_filename = filename[(folder_prefix_length)..-1]
        match = rel_filename.match(%r{(?<subfolder>.*\/)?(?<file>.*)})
        match[:file]
      end
    end
  end
end
