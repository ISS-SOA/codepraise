# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
class VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  GITUB_CASSETTE = 'github_api'

  def self.setup_vcr
    VCR.configure do |c|
      c.cassette_library_dir = CASSETTES_FOLDER
      c.hook_into :webmock
      c.ignore_localhost = true
    end
  end

  def self.configure_vcr_for_github(recording: :new_episodes)
    VCR.configure do |c|
      c.filter_sensitive_data('<GITHUB_TOKEN>') { GITHUB_TOKEN }
      c.filter_sensitive_data('<GITHUB_TOKEN_ESC>') { CGI.escape(GITHUB_TOKEN) }
    end

    VCR.insert_cassette(
      GITUB_CASSETTE,
      record: recording,
      match_requests_on: %i[method uri headers],
      allow_playback_repeats: true
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
