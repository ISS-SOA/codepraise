# frozen_string_literal: true

require_relative 'helpers/spec_helper.rb'
require_relative 'helpers/vcr_helper.rb'
require_relative 'helpers/database_helper.rb'

describe 'Test Git Commands Mapper and Gateway' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_github
    DatabaseHelper.wipe_database

    gh_project = CodePraise::Github::ProjectMapper.
      new(GITHUB_TOKEN).
      find(USERNAME, PROJECT_NAME)

    project = CodePraise::Repository::For.entity(gh_project).
      create(gh_project)

    @gitrepo = CodePraise::GitRepo.new(project)
    @gitrepo.clone! unless @gitrepo.exists_locally?
  end

  after do
    VcrHelper.eject_vcr
  end

  it 'HAPPY: should get contributions summary for entire repo' do
    summary = CodePraise::Praise::Contributions.new(@gitrepo).for_folder('')
    _(summary.subfolders.count).must_equal 10
    _(summary.base_files.count).must_equal 2
    _(summary.base_files.keys.first).must_equal 'init.rb'
    _(summary.subfolders.keys.first).must_equal 'views_objects'
  end

  it 'HAPPY: should get accurate contributions summary for specific folder' do
    summary = CodePraise::Praise::Contributions.new(@gitrepo).for_folder('forms')

    _(summary.subfolders.count).must_equal 1
    _(summary.subfolders['errors']).must_be_nil

    _(summary.base_files.count).must_equal 2

    _(summary.base_files['url_request.rb']['<b37582000@gmail.com>'])
      .must_equal({:count=>7, :name=>"luyimin"})

    _(summary.base_files['url_request.rb']['<orange6318@hotmail.com>'])
      .must_equal({:count=>2, :name=>"SOA-KunLin"})

    _(summary.base_files['init.rb']['<b37582000@gmail.com>'])
      .must_equal({:count=>6, :name=>"luyimin"})
  end
end
