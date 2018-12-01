# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'contributor_representer'
require_relative 'credit_share_representer'
require_relative 'file_path_representer'
require_relative 'line_contribution_representer'

module CodePraise
  module Representer
    # Represents folder summary about repo's folder
    class FileContributions < Roar::Decorator
      include Roar::JSON

      property :line_count
      property :total_credits
      property :file_path, extend: Representer::FilePath, class: OpenStruct
      property :credit_share, extend: Representer::CreditShare, class: OpenStruct
      collection :contributors, extend: Representer::Contributor, class: OpenStruct
    end
  end
end
