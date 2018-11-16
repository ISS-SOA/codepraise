# frozen_string_literal: true

require_relative '../helpers/acceptance_helper.rb'
require_relative 'pages/home_page.rb'

describe 'Homepage Acceptance Tests' do
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

  describe 'Visit Home page' do
    it '(HAPPY) should not see projects if none created' do
      # GIVEN: user has no projects
      # WHEN: they visit the home page
      visit HomePage do |page|
        # THEN: they should see basic headers, no projects and a welcome message
        _(page.title_heading).must_equal 'CodePraise'
        _(page.url_input_element.present?).must_equal true
        _(page.add_button_element.present?).must_equal true
        _(page.projects_table_element.exists?).must_equal false

        _(page.success_message_element.present?).must_equal true
        _(page.success_message.downcase).must_include 'start'
      end
    end

    it '(HAPPY) should not see projects they did not request' do
      # GIVEN: a project exists in the database but user has not requested it
      project = CodePraise::Github::ProjectMapper
        .new(GITHUB_TOKEN)
        .find(USERNAME, PROJECT_NAME)
      CodePraise::Repository::For.entity(project).create(project)

      # WHEN: user goes to the homepage
      visit HomePage do |page|
        # THEN: they should not see any projects
        _(page.projects_table_element.exists?).must_equal false
      end
    end
  end

  describe 'Add Project' do
    it '(HAPPY) should be able to request a project' do
      # GIVEN: user is on the home page without any projects
      visit HomePage do |page|
        # WHEN: they add a project URL and submit
        good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
        page.add_new_project(good_url)

        # THEN: they should find themselves on the project's page
        @browser.url.include? USERNAME
        @browser.url.include? PROJECT_NAME
      end
    end

    it '(HAPPY) should be able to see requested projects listed' do
      # GIVEN: user has requested a project
      visit HomePage do |page|
        good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
        page.add_new_project(good_url)
      end

      # WHEN: they return to the home page
      visit HomePage do |page|
        # THEN: they should see their project's details listed
        _(page.projects_table_element.exists?).must_equal true
        _(page.num_projects).must_equal 1
        _(page.first_project.text).must_include USERNAME
        _(page.first_project.text).must_include PROJECT_NAME
      end
    end

    it '(HAPPY) should see project highlighted when they hover over it' do
      # GIVEN: user has requested a project to watch
      good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
      visit HomePage do |page|
        page.add_new_project(good_url)
      end

      # WHEN: they go to the home page
      visit HomePage do |page|
        # WHEN: ..and hover over their new project
        page.first_project_hover

        # THEN: the new project should get highlighted
        _(page.first_project_highlighted?).must_equal true
      end
    end

    it '(BAD) should not be able to add an invalid project URL' do
      # GIVEN: user is on the home page without any projects
      visit HomePage do |page|
        # WHEN: they request a project with an invalid URL
        bad_url = 'foobar'
        page.add_new_project(bad_url)

        # THEN: they should see a warning message
        _(page.warning_message.downcase).must_include 'invalid'
      end
    end

    it '(SAD) should not be able to add valid but non-existent project URL' do
      # GIVEN: user is on the home page without any projects
      visit HomePage do |page|
        # WHEN: they add a project URL that is valid but non-existent
        sad_url = "https://github.com/#{USERNAME}/foobar"
        page.add_new_project(sad_url)

        # THEN: they should see a warning message
        _(page.warning_message.downcase).must_include 'could not find'
      end
    end
  end

  describe 'Delete Project' do
    it '(HAPPY) should be able to delete a requested project' do
      # GIVEN: user has requested and created a project
      visit HomePage do |page|
        good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
        page.add_new_project(good_url)
      end

      # WHEN: they revisit the homepage and delete the project
      visit HomePage do |page|
        page.first_project_delete

        # THEN: they should not find any projects
        _(page.projects_table_element.exists?).must_equal false
      end
    end
  end
end
