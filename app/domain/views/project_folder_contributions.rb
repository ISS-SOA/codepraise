# frozen_string_literal: true

require_relative 'project_file_contributions'

module Views
  # View for folder contributions for a given project
  class ProjectFolderContributions
    def initialize(project, folder, index = nil)
      @project = Project.new(project)
      @folder = folder
      @index = index
    end

    def subfolders
      @folder.subfolders.map.with_index do |sub, i|
        ProjectFolderContributions.new(@project.entity, sub, i)
      end
    end

    def files
      @folder.base_files.map { |file| ProjectFileContributions.new(file) }
    end

    def full_path
      "/project/#{@project.owner_name}/#{project_name}/#{@folder.path}"
    end

    def rel_path
      @folder.path
    end

    def percent_credit_of(contributor_view)
      @folder.percent_credit_of(contributor_view.entity)
    end

    def num_lines_by(contributor_view)
      @folder.lines_by(contributor_view.entity).count
    end

    def owner_name
      @project.owner_name
    end

    def project_name
      @project.name
    end

    def http_url
      @project.http_url
    end

    def contributors
      @folder.contributors.map { |contributor| Contributor.new(contributor) }
    end

    def num_contributors
      @folder.contributors.count
    end

    def any_subfolders?
      @folder.any_subfolders?
    end
  end
end
