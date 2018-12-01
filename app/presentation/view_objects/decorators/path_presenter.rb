# frozen_string_literal: true

module Views
  # path to a project or folder
  class PathPresenter
    def self.to_project(owner_name, project_name)
      "/project/#{owner_name}/#{project_name}"
    end

    def self.to_folder(owner_name, project_name, folder_path)
      "/project/#{owner_name}/#{project_name}/#{folder_path}"
    end

    def self.path_leaf(path)
      path.split('/').last
    end
  end
end
