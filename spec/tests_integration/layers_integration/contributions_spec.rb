# frozen_string_literal: true

require_relative '../../helpers/spec_helper.rb'
require_relative '../../helpers/vcr_helper.rb'
require_relative '../../helpers/database_helper.rb'

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
    root = CodePraise::Mapper::Contributions.new(@gitrepo).for_folder('')
    _(root.subfolders.count).must_equal 10
    _(root.base_files.count).must_equal 2

    _(root.base_files.first.file_path.filename).must_equal 'init.rb'
    _(root.subfolders.first.path).must_equal 'views_objects'

    _(root.subfolders.map(&:credit_share).reduce(&:+) +
      root.base_files.map(&:credit_share).reduce(&:+))
      .must_equal(root.credit_share)
  end

  it 'HAPPY: should get accurate contributions summary for specific folder' do
    forms = CodePraise::Mapper::Contributions.new(@gitrepo).for_folder('forms')

    _(forms.subfolders.count).must_equal 1
    _(forms.subfolders.count).must_equal 1

    _(forms.base_files.count).must_equal 2

    count = forms['url_request.rb'].credit_share.by_email 'b37582000@gmail.com'
    _(count).must_equal 5

    count = forms['url_request.rb'].credit_share.by_email 'orange6318@hotmail.com'
    _(count).must_equal 2

    count = forms['init.rb'].credit_share.by_email 'b37582000@gmail.com'
    _(count).must_equal 4
  end
end
