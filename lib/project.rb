# frozen_string_literal: false

require_relative 'contributor.rb'

module CodePraise
  # Model for Project
  class Project
    def initialize(project_data, data_source)
      @project = project_data
      @data_source = data_source
    end

    def size
      @project['size']
    end

    def owner
      @owner ||= Contributor.new(@project['owner'])
    end

    def git_url
      @project['git_url']
    end

    def contributors
      @contributors ||= @data_source.contributors(@project['contributors_url'])
    end
  end
end
