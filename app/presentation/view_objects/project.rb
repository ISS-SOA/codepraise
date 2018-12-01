# frozen_string_literal: true

module Views
  # View for a single project entity
  class Project
    def initialize(project, index = nil)
      @project = project
      @index = index
    end

    def entity
      @project
    end

    def praise_link
      "/project/#{fullname}"
    end

    def index_str
      "project[#{@index}]"
    end

    def contributor_names
      @project.contributors.map(&:username).join(', ')
    end

    def owner_name
      @project.owner.username
    end

    def fullname
      "#{owner_name}/#{name}"
    end

    def http_url
      @project.http_url
    end

    def name
      @project.name
    end
  end
end
