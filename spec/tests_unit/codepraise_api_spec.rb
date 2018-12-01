# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Unit test of CodePraise API gateway' do
  it 'must report alive status' do
    alive = CodePraise::Gateway::Api.new(CodePraise::App.config).alive?
    _(alive).must_equal true
  end

  it 'must be able to add a project' do
    res = CodePraise::Gateway::Api.new(CodePraise::App.config)
      .add_project(USERNAME, PROJECT_NAME)

    _(res.success?).must_equal true
    _(res.parse.keys.count).must_be :>=, 5
  end

  it 'must return a list of projects' do
    # GIVEN a project is in the database
    CodePraise::Gateway::Api.new(CodePraise::App.config)
      .add_project(USERNAME, PROJECT_NAME)

    # WHEN we request a list of projects
    list = [[USERNAME, PROJECT_NAME].join('/')]
    res = CodePraise::Gateway::Api.new(CodePraise::App.config)
      .projects_list(list)

    # THEN we should see a single project in the list
    _(res.success?).must_equal true
    data = res.parse
    _(data.keys).must_include 'projects'
    _(data['projects'].count).must_equal 1
    _(data['projects'].first.keys.count).must_be :>=, 5
  end

  it 'must return a project appraisal' do
    # GIVEN a project is in the database
    CodePraise::Gateway::Api.new(CodePraise::App.config)
      .add_project(USERNAME, PROJECT_NAME)

    # WHEN we request an appraisal
    req = OpenStruct.new(
      project_fullname: USERNAME + '/' + PROJECT_NAME,
      owner_name: USERNAME,
      project_name: PROJECT_NAME,
      foldername: ''
    )

    res = CodePraise::Gateway::Api.new(CodePraise::App.config)
      .appraise(req)

    # THEN we should see a single project in the list
    _(res.success?).must_equal true
    data = res.parse
    _(data.keys).must_include 'project'
    _(data.keys).must_include 'folder'
  end
end
