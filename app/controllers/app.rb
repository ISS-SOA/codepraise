# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module CodePraise
  # Web App
  class App < Roda
    plugin :halt
    plugin :all_verbs
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, path: 'app/views/assets',
                    css: 'style.css', js: 'table_row.js'

    route do |routing| # rubocop:disable Metrics/BlockLength
      routing.assets # load CSS

      # GET /
      routing.root do
        # Get cookie viewer's previously seen projects

        # Using cookies:
          # watching_cookie = routing.cookies['watching']
          # watching =
          #   if watching_cookie.nil? || watching_cookie.empty?
          #     []
          #   else
          #     JSON.parse(watching_cookie)
          #   end
        session[:watching] ||= []

        # Load previously viewed projects
        projects = Repository::For.klass(Entity::Project)
          .find_full_names(session[:watching])
        # response.set_cookie('watching', projects.map(&:fullname))
        session[:watching] = projects.map(&:fullname)

        if projects.none?
          flash.now[:notice] = 'Add a Github project to get started'
        end

        view 'home', locals: { projects: projects }
      end

      routing.on 'project' do
        routing.is do
          # POST /project/
          routing.post do
            gh_url = routing.params['github_url']
            unless (gh_url.include? 'github.com') &&
                    (gh_url.split('/').count == 5)
              flash[:error] = 'Invalid URL for a Github project'
              routing.redirect '/'
            end

            owner_name, project_name = gh_url.split('/')[-2..-1]

            # Add project to database
            project = Repository::For.klass(Entity::Project)
              .find_full_name(owner_name, project_name)

            unless project
              # Get project from Github
              begin
                project = Github::ProjectMapper
                  .new(App.config.GITHUB_TOKEN)
                  .find(owner_name, project_name)
              rescue StandardError => error
                flash[:error] = 'Could not find that Github project'
                routing.redirect '/'
              end

              # Add project to database
              begin
                Repository::For.entity(project).create(project)
              rescue StandardError => error
                puts error.backtrace.join("\n")
                flash[:error] = 'Having trouble accessing the database'
              end
            end

            # Add new project to watched set in cookies
            # Using Cookies:
              # watching_cookie = routing.cookies['watching']
              # watching =
              #   if watching_cookie.nil? || watching_cookie.empty?
              #     []
              #   else
              #     JSON.parse(routing.cookies['watching'])
              #   end
              # new_watching = watching.to_set.add(project.fullname)
              # response.set_cookie('watching', new_watching.to_a.to_json)
            session[:watching] =
              session[:watching].to_set.add(project.fullname).to_a

            # Redirect viewer to project page
            routing.redirect "project/#{project.owner.username}/#{project.name}"
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
            path = request.remaining_path
            folder_name = path.empty? ? '' : path[1..-1]

            # Get project from database instead of Github
            begin
              project = Repository::For.klass(Entity::Project)
                .find_full_name(owner_name, project_name)

              if project.nil?
                flash[:error] = 'Project not found'
                routing.redirect '/'
              end
            rescue StandardError => error
              flash[:error] = 'Having trouble accessing the database'
              routing.redirect '/'
            end

            # Clone remote repo from project information
            begin
              gitrepo = GitRepo.new(project)
              gitrepo.clone! unless gitrepo.exists_locally?
            rescue StandardError => error
              puts error.backtrace.join("\n")
              flash[:error] = 'Could not clone this project'
              routing.redirect '/'
            end

            # Compile contributions for folder
            begin
              folder = Mapper::Contributions
                .new(gitrepo).for_folder(folder_name)
            rescue StandardError => error
              # puts "ERROR: Mapper::Contributions#for_folder"
              # puts [error.inspect, error.backtrace].flatten.join("\n")
              flash[:error] = 'Could not find that folder'
              routing.redirect "/project/#{owner_name}/#{project_name}"
            end

            if folder.empty?
              flash[:error] = 'Could not find that folder'
              routing.redirect "/project/#{owner_name}/#{project_name}"
            end

            # Show viewer the project
            view 'project', locals: { project: project, folder: folder }
          end
        end
      end
    end
  end
end
