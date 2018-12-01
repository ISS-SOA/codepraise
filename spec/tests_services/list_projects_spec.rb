# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Integration test of ListProjects service and API gateway' do
  it 'must return a list of projects' do
    # GIVEN a project is in the database
    CodePraise::Gateway::Api.new(CodePraise::App.config)
      .add_project(USERNAME, PROJECT_NAME)

    # WHEN we request a list of projects
    list = [[USERNAME, PROJECT_NAME].join('/')]
    res = CodePraise::Service::ListProjects.new.call(list)

    # THEN we should see a single project in the list
    _(res.success?).must_equal true
    list = res.value!
    _(list.projects.count).must_equal 1
    _(list.projects.first.owner.username).must_equal USERNAME
  end

  it 'must return and empty list if we specify none' do
    # WHEN we request a list of projects
    list = []
    res = CodePraise::Service::ListProjects.new.call(list)

    # THEN we should see a no projects in the list
    _(res.success?).must_equal true
    list = res.value!
    _(list.projects.count).must_equal 0
  end
end
