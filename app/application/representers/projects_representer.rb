# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'project_representer'

module CodePraise
  module Representer
    # Represents list of projects for API output
    class ProjectsList < Roar::Decorator
      include Roar::JSON

      collection :projects, extend: Representer::Project,
                            class: Value::OpenStructWithLinks
    end
  end
end
