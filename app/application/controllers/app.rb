# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require_relative 'helpers.rb'

module CodePraise
  # Web App
  class App < Roda
    include RouteHelpers

    plugin :halt
    plugin :flash
    plugin :all_verbs
    plugin :caching
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css', js: 'table_row.js'

    use Rack::MethodOverride

    route do |routing|
      routing.assets # load CSS

      # GET /
      routing.root do
        # Get cookie viewer's previously seen projects
        session[:watching] ||= []

        result = Service::ListProjects.new.call(session[:watching])

        if result.failure?
          flash[:error] = result.failure
          projects = []
        else
          projects = result.value!.projects
          if projects.none?
            flash.now[:notice] = 'Add a Github project to get started'
          end
        end

        session[:watching] = projects.map(&:fullname)

        viewable_projects = Views::ProjectsList.new(projects)
        view 'home', locals: { projects: viewable_projects }
      end

      routing.on 'project' do
        routing.is do
          # POST /project/
          routing.post do
            url_request = Forms::UrlRequest.call(routing.params)
            project_made = Service::AddProject.new.call(url_request)

            if project_made.failure?
              flash[:error] = project_made.failure
              routing.redirect '/'
            end

            project = project_made.value!
            session[:watching].insert(0, project.fullname).uniq!
            flash[:notice] = 'Project added to your list'
            # routing.redirect "project/#{project.owner.username}/#{project.name}"
            routing.redirect '/'
          end
        end

        routing.on String, String do |owner_name, project_name|
          # DELETE /project/{owner_name}/{project_name}
          routing.delete do
            fullname = "#{owner_name}/#{project_name}"
            session[:watching].delete(fullname)

            routing.redirect '/'
          end

          # GET /project/{owner_name}/{project_name}[/folder_namepath/]
          routing.get do
            path_request = ProjectRequestPath.new(
              owner_name, project_name, request
            )

            session[:watching] ||= []

            result = Service::AppraiseProject.new.call(
              watched_list: session[:watching],
              requested: path_request
            )

            if result.failure?
              flash[:error] = result.failure
              routing.redirect '/'
            end

            appraised = result.value!
            proj_folder = Views::ProjectFolderContributions.new(
              appraised[:project], appraised[:folder]
            )

            # Show viewer the project
            response.expires 60, public: true
            view 'project', locals: { proj_folder: proj_folder }
          end
        end
      end
    end
  end
end
