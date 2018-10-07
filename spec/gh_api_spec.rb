# frozen_string_literal: false

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative '../lib/github_api.rb'

describe 'Tests Github API library' do
  USERNAME = 'soumyaray'.freeze
  PROJECT_NAME = 'YPBT-app'.freeze
  CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
  GH_TOKEN = CONFIG['GH_TOKEN']
  CORRECT = YAML.safe_load(File.read('spec/fixtures/gh_results.yml'))
  RESPONSE = YAML.load(File.read('spec/fixtures/gh_response.yml'))

  describe 'Project information' do
    it 'HAPPY: should provide correct project attributes' do
      project = CodePraise::GithubAPI.new(GH_TOKEN)
                                     .project(USERNAME, PROJECT_NAME)
      _(project.size).must_equal CORRECT['size']
      _(project.git_url).must_equal CORRECT['git_url']
    end

    it 'SAD: should raise exception on incorrect project' do
      proc do
        CodePraise::GithubAPI.new(GH_TOKEN).project('soumyaray', 'foobar')
      end.must_raise CodePraise::GithubAPI::Errors::NotFound
    end

    it 'SAD: should raise exception when unauthorized' do
      proc do
        CodePraise::GithubAPI.new('BAD_TOKEN').project('soumyaray', 'foobar')
      end.must_raise CodePraise::GithubAPI::Errors::Unauthorized
    end
  end

  describe 'Contributor information' do
    before do
      @project = CodePraise::GithubAPI.new(GH_TOKEN)
                                         .project(USERNAME, PROJECT_NAME)
    end

    it 'HAPPY: should recognize owner' do
      _(@project.owner).must_be_kind_of CodePraise::Contributor
    end

    it 'HAPPY: should identify owner' do
      _(@project.owner.username).wont_be_nil
      _(@project.owner.username).must_equal CORRECT['owner']['login']
    end

    it 'HAPPY: should identify contributors' do
      contributors = @project.contributors
      _(contributors.count).must_equal CORRECT['contributors'].count

      usernames = contributors.map(&:username)
      correct_usernames = CORRECT['contributors'].map { |c| c['login'] }
      _(usernames).must_equal correct_usernames
    end
  end
end
