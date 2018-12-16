# frozen_string_literal: true

module Views
  # View object to capture progress bar information
  class AppraisalProcessing
    def initialize(config, response)
      @response = response
      @config = config
    end

    def in_progress?
      @response.processing?
    end

    def ws_channel_id
      @response.message['request_id'] if in_progress?
    end

    def ws_javascript
      @config.API_HOST + '/faye/faye.js' if in_progress?
    end

    def ws_route
      @config.API_HOST + '/faye/faye' if in_progress?
    end
  end
end
