# frozen_string_literal: true

require_relative '../../helpers/spec_helper.rb'
require_relative '../../helpers/vcr_helper.rb'
require_relative '../../helpers/database_helper.rb'

describe 'Integration Tests of Github API and Database' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_github
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store project' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to save remote git repo data to database' do
      project = CodePraise::Github::ProjectMapper
        .new(GITHUB_TOKEN)
        .find(USERNAME, PROJECT_NAME)

      rebuilt = CodePraise::Repository::For.entity(project).create(project)

      _(rebuilt.origin_id).must_equal(project.origin_id)
      _(rebuilt.name).must_equal(project.name)
      _(rebuilt.size).must_equal(project.size)
      _(rebuilt.ssh_url).must_equal(project.ssh_url)
      _(rebuilt.http_url).must_equal(project.http_url)
      _(rebuilt.contributors.count).must_equal(project.contributors.count)

      project.contributors.each do |member|
        found = rebuilt.contributors.find do |potential|
          potential.origin_id == member.origin_id
        end

        _(found.username).must_equal member.username
        _(found.email).must_equal member.email
      end
    end
  end
end
