# frozen_string_literal: true

require_relative '../../helpers/spec_helper.rb'
require_relative '../../helpers/vcr_helper.rb'
require_relative '../../helpers/database_helper.rb'

require 'ostruct'

describe 'AppraiseProject Service Integration Test' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_github(recording: :none)
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Appraise a Project' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should give contributions for a folder of an existing project' do
      # GIVEN: a valid project that exists locally and is being watched
      gh_project = CodePraise::Github::ProjectMapper
        .new(GITHUB_TOKEN)
        .find(USERNAME, PROJECT_NAME)
      CodePraise::Repository::For.entity(gh_project).create(gh_project)

      # WHEN: we request to appraise the project
      request = OpenStruct.new(
        owner_name: USERNAME,
        project_name: PROJECT_NAME,
        project_fullname: USERNAME + '/' + PROJECT_NAME,
        folder_name: ''
      )

      appraisal = CodePraise::Service::AppraiseProject.new.call(
        watched_list: [request.project_fullname],
        requested: request
      ).value!

      # THEN: we should get an appraisal
      _(%i[project folder] & appraisal.keys).must_equal %i[project folder]
      folder = appraisal[:folder]
      _(folder).must_be_kind_of CodePraise::Entity::FolderContributions
      _(folder.subfolders.count).must_equal 10
      _(folder.base_files.count).must_equal 2

      _(folder.base_files.first.file_path.filename).must_equal 'init.rb'
      _(folder.subfolders.first.path).must_equal 'views_objects'

      _(folder.subfolders.map(&:credit_share).reduce(&:+) +
        folder.base_files.map(&:credit_share).reduce(&:+))
        .must_equal(folder.credit_share)
    end

    it 'SAD: should not give contributions for an unwatched project' do
      # GIVEN: a valid project that exists locally and is being watched
      gh_project = CodePraise::Github::ProjectMapper
        .new(GITHUB_TOKEN)
        .find(USERNAME, PROJECT_NAME)
      CodePraise::Repository::For.entity(gh_project).create(gh_project)

      # WHEN: we request to appraise the project
      request = OpenStruct.new(
        owner_name: USERNAME,
        project_name: PROJECT_NAME,
        project_fullname: USERNAME + '/' + PROJECT_NAME,
        folder_name: ''
      )

      result = CodePraise::Service::AppraiseProject.new.call(
        watched_list: [],
        requested: request
      )

      # THEN: we should get failure
      _(result.failure?).must_equal true
    end

    it 'SAD: should not give contributions for non-existent project' do
      # GIVEN: no project exists locally

      # WHEN: we request to appraise the project
      request = OpenStruct.new(
        owner_name: USERNAME,
        project_name: PROJECT_NAME,
        project_fullname: USERNAME + '/' + PROJECT_NAME,
        folder_name: ''
      )

      result = CodePraise::Service::AppraiseProject.new.call(
        watched_list: [],
        requested: request
      )

      # THEN: we should get failure
      _(result.failure?).must_equal true
    end
  end
end
