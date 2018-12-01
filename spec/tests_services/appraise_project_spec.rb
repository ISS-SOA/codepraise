# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Integration test of AddProject service and API gateway' do
  it 'must get the appraisal of an existing project' do
    req = OpenStruct.new(
      project_fullname: USERNAME + '/' + PROJECT_NAME,
      owner_name: USERNAME,
      project_name: PROJECT_NAME,
      foldername: ''
    )
    watched_list = [req.project_fullname]

    # WHEN we request to add a project
    res = CodePraise::Service::AppraiseProject.new.call(
      watched_list: watched_list, requested: req
    )

    # THEN we should see a single project in the list
    _(res.success?).must_equal true
    appraisal = res.value!
    _(appraisal.to_h.keys.sort).must_equal %i[folder project]
    _(appraisal.project.owner.username).must_equal USERNAME
    _(appraisal.folder.any_base_files?).must_equal true
  end
end
