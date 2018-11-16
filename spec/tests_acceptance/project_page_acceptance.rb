# frozen_string_literal: true

require_relative '../helpers/acceptance_helper.rb'
require_relative 'pages/project_page.rb'
require_relative 'pages/home_page.rb'

describe 'Project Page Acceptance Tests' do
  include PageObject::PageFactory

  DatabaseHelper.setup_database_cleaner

  before do
    DatabaseHelper.wipe_database
    @headless = Headless.new
    @browser = Watir::Browser.new
  end

  after do
    @browser.close
    @headless.destroy
  end

  it '(HAPPY) should see project content if project exists' do
    # GIVEN: user has requested and created a project
    visit HomePage do |page|
      good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
      page.add_new_project(good_url)
    end

    # WHEN: user goes to the project page
    visit(ProjectPage, using_params: { owner_name: USERNAME,
                                       project_name: PROJECT_NAME }) do |page|
      # THEN: they should see the project details
      _(page.project_title).must_include USERNAME
      _(page.project_title).must_include PROJECT_NAME
      _(page.contribution_table_element.present?).must_equal true

      usernames = ['SOA-KunLin', 'Yuan Yu', 'luyimin']
      _(usernames.include?(page.contributors[0].username)).must_equal true
      _(usernames.include?(page.contributors[1].username)).must_equal true
      _(usernames.include?(page.contributors[3].username)).must_equal true

      _(page.folders.count).must_equal 10
      _(page.files.count).must_equal 2
    end
  end

  it '(HAPPY) should be able to traverse to subfolders' do
    # GIVEN: user has created a project
    visit HomePage do |page|
      good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
      page.add_new_project(good_url)
    end

    # WHEN: they go to the project's page
    visit(ProjectPage, using_params: { owner_name: USERNAME,
                                       project_name: PROJECT_NAME }) do |page|
      # WHEN: and click a link to a folder
      page.folder_called('views_objects/').link.click

      # THEN: they should see the project and contribution details
      _(page.folders.count).must_equal 0
      _(page.files.count).must_equal 5
    end
  end

  it '(BAD) should report error if subfolder does not exist' do
    # GIVEN: user has created a project
    visit HomePage do |page|
      good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
      page.add_new_project(good_url)
    end

    # WHEN user goes to a non-existent folder of the project
    visit(ProjectPage,
          using_params: { owner_name: USERNAME,
                          project_name: PROJECT_NAME,
                          folder: 'foobar' })

    # THEN: user should see a warning message
    on_page HomePage do |page|
      _(page.warning_message.downcase).must_include 'could not find'
    end
  end

  it '(HAPPY) should report an error if project not requested' do
    # GIVEN: user has not requested a project yet, even though it exists
    project = CodePraise::Github::ProjectMapper
      .new(GITHUB_TOKEN)
      .find(USERNAME, PROJECT_NAME)
    CodePraise::Repository::For.entity(project).create(project)

    # WHEN: they go directly to the project's page
    visit(ProjectPage, using_params: { owner_name: USERNAME,
                                       project_name: PROJECT_NAME })

    # THEN: they should should be returned to the homepage with a warning
    on_page HomePage do |page|
      _(page.warning_message.downcase).must_include 'request'
    end
  end
end
