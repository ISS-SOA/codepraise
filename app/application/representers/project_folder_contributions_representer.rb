# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'folder_contributions_representer'
require_relative 'project_representer'

module CodePraise
  module Representer
    # Represents folder summary about repo's folder
    class ProjectFolderContributions < Roar::Decorator
      include Roar::JSON

      property :project, extend: Representer::Project, class: OpenStruct
      property :folder, extend: Representer::FolderContributions, class: OpenStruct
    end
  end
end
