# frozen_string_literal: true

module CodePraise
  module RouteHelpers
    # Application value for the path of a requested project
    class ProjectRequestPath
      def initialize(owner_name, project_name, request)
        @owner_name = owner_name
        @project_name = project_name
        @request = request
        @path = request.remaining_path
      end

      attr_reader :owner_name, :project_name

      def folder_name
        @folder_name ||= @path.empty? ? '' : @path[1..-1]
      end

      def project_fullname
        @request.captures.join '/'
      end
    end
  end
end
