# frozen_string_literal: true

module CodePraise
  module Value
    # OpenStruct for deserializing json with hypermedia
    class OpenStructWithLinks < OpenStruct
      attr_accessor :links
    end
  end
end
