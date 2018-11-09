# frozen_string_literal: true

module Views
  # View for a single project entity
  class ProjectFileContributions
    def initialize(file)
      @file = file
    end

    def filename
      @file.file_path.filename
    end

    def num_lines_by(contributor_view)
      @file.lines_by(contributor_view.entity).count
    end
  end
end
