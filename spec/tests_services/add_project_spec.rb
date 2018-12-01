# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Integration test of AddProject service and API gateway' do
  it 'must add a legitimate project' do
    # WHEN we request to add a project
    url_request = CodePraise::Forms::UrlRequest.call(remote_url: GH_URL)

    res = CodePraise::Service::AddProject.new.call(url_request)

    # THEN we should see a single project in the list
    _(res.success?).must_equal true
    project = res.value!
    _(project.owner.username).must_equal USERNAME
  end
end
