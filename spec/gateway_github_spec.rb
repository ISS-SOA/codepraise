# frozen_string_literal: false

require_relative 'spec_helper.rb'

describe 'Tests Github API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<GITHUB_TOKEN>') { GH_TOKEN }
    c.filter_sensitive_data('<GITHUB_TOKEN_ESC>') { CGI.escape(GH_TOKEN) }
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Project information' do
    it 'HAPPY: should provide correct project attributes' do
      project =
        CodePraise::Github::ProjectMapper
          .new(GH_TOKEN)
          .find(USERNAME, PROJECT_NAME)
      _(project.size).must_equal CORRECT['size']
      _(project.git_url).must_equal CORRECT['git_url']
    end

    it 'BAD: should raise exception on incorrect project' do
      proc do
        CodePraise::Github::ProjectMapper
          .new(GH_TOKEN)
          .find(USERNAME, 'foobar')
      end.must_raise CodePraise::Github::Api::Response::NotFound
    end

    it 'BAD: should raise exception when unauthorized' do
      proc do
        CodePraise::Github::ProjectMapper
          .new('BAD_TOKEN')
          .find(USERNAME, PROJECT_NAME)
      end.must_raise CodePraise::Github::Api::Response::Unauthorized
    end
  end

  describe 'Contributor information' do
    before do
      @project = CodePraise::Github::ProjectMapper
        .new(GH_TOKEN)
        .find(USERNAME, PROJECT_NAME)
    end

    it 'HAPPY: should recognize owner' do
      _(@project.owner).must_be_kind_of CodePraise::Entity::Member
    end

    it 'HAPPY: should identify owner' do
      _(@project.owner.username).wont_be_nil
      _(@project.owner.username).must_equal CORRECT['owner']['login']
    end

    it 'HAPPY: should identify members' do
      members = @project.members
      _(members.count).must_equal CORRECT['contributors'].count

      usernames = members.map(&:username)
      correct_usernames = CORRECT['contributors'].map { |c| c['login'] }
      _(usernames).must_equal correct_usernames
    end
  end
end
