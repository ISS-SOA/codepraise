# frozen_string_literal: true

require_relative 'helpers/spec_helper.rb'
require_relative 'helpers/database_helper.rb'
require 'headless'
require 'watir'

describe 'Acceptance Tests' do
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

  describe 'Homepage' do
    describe 'Visit Home page' do
      it '(HAPPY) should not see projects if none created' do
        # GIVEN: user is on the home page without any projects
        @browser.goto homepage

        # THEN: user should see basic headers, no projects and a welcome message
        _(@browser.h1(id: 'main_header').text).must_equal 'CodePraise'
        _(@browser.text_field(id: 'url_input').present?).must_equal true
        _(@browser.button(id: 'project_form_submit').present?).must_equal true
        _(@browser.table(id: 'projects_table').exists?).must_equal false

        _(@browser.div(id: 'flash_bar_success').present?).must_equal true
        _(@browser.div(id: 'flash_bar_success').text.downcase).must_include 'start'
      end

      it '(HAPPY) should not see projects they did not request' do
        # GIVEN: a project exists in the database but user has not requested it
        project = CodePraise::Github::ProjectMapper
          .new(GITHUB_TOKEN)
          .find(USERNAME, PROJECT_NAME)
        CodePraise::Repository::For.entity(project).create(project)

        # WHEN: user goes to the homepage
        @browser.goto homepage

        # THEN: they should not see any projects
        _(@browser.table(id: 'projects_table').exists?).must_equal false
      end
    end

    describe 'Add Project' do
      it '(HAPPY) should be able to request a project' do
        # GIVEN: user is on the home page without any projects
        @browser.goto homepage

        # WHEN: they add a project URL and submit
        good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
        @browser.text_field(id: 'url_input').set(good_url)
        @browser.button(id: 'project_form_submit').click

        # THEN: they should find themselves on the project's page
        @browser.url.include? USERNAME
        @browser.url.include? PROJECT_NAME
      end

      it '(HAPPY) should be able to see requested projects listed' do
        # GIVEN: user is on the home page without any projects
        @browser.goto homepage

        # WHEN: they add a project URL and submit
        good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
        @browser.text_field(id: 'url_input').set(good_url)
        @browser.button(id: 'project_form_submit').click
        # and then return to the home page
        @browser.goto homepage

        # THEN: they should see their project's details listed
        table = @browser.table(id: 'projects_table')
        project_rows = table.trs(class: 'project_row')
        new_row = project_rows.first

        _(table.exists?).must_equal true
        _(project_rows.count).must_equal 1
        _(new_row.text).must_include USERNAME
        _(new_row.text).must_include PROJECT_NAME
      end

      it '(HAPPY) should see project highlighted when they hover over it' do
        # GIVEN: user is on homepage with requests project
        @browser.goto homepage
        good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
        @browser.text_field(id: 'url_input').set(good_url)
        @browser.button(id: 'project_form_submit').click
        @browser.goto homepage

        # WHEN: they hover over their new project
        table = @browser.table(id: 'projects_table')
        project_rows = table.trs(class: 'project_row')
        new_row = project_rows.first
        old_highlight = new_row.style('background-color')
        new_row.hover

        # THEN: the new project should get highlighted
        new_highlight = new_row.style('background-color')
        _(old_highlight).wont_equal new_highlight
      end

      it '(BAD) should not be able to add an invalid project URL' do
        # GIVEN: user is on the home page without any projects
        @browser.goto homepage

        # WHEN: they request a project with an invalid URL
        bad_url = 'foobar'
        @browser.text_field(id: 'url_input').set(bad_url)
        @browser.button(id: 'project_form_submit').click

        # THEN: they should see a warning message
        _(@browser.div(id: 'flash_bar_danger').present?).must_equal true
        _(@browser.div(id: 'flash_bar_danger').text.downcase).must_include 'invalid'
      end

      it '(SAD) should not be able to add valid but non-existent project URL' do
        # GIVEN: user is on the home page without any projects
        @browser.goto homepage

        # WHEN: they add a project URL that is valid but non-existent
        sad_url = "https://github.com/#{USERNAME}/foobar"
        @browser.text_field(id: 'url_input').set(sad_url)
        @browser.button(id: 'project_form_submit').click

        # THEN: they should see a warning message
        _(@browser.div(id: 'flash_bar_danger').present?).must_equal true
        _(@browser.div(id: 'flash_bar_danger').text.downcase).must_include 'could not find'
      end
    end

    describe 'Delete Project' do
      it '(HAPPY) should be able to delete a requested project' do
        # GIVEN: user has requested and created a project
        @browser.goto homepage
        good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
        @browser.text_field(id: 'url_input').set(good_url)
        @browser.button(id: 'project_form_submit').click

        # WHEN: they revisit the homepage and delete the project
        @browser.goto homepage
        @browser.button(id: 'project[0].delete').click

        # THEN: they should not find any projects
        _(@browser.table(id: 'projects_table').exists?).must_equal false
      end
    end
  end

  describe 'Project Page' do
    it '(HAPPY) should see project content if project exists' do
      # GIVEN: user has requested and created a project
      @browser.goto homepage
      good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
      @browser.text_field(id: 'url_input').set(good_url)
      @browser.button(id: 'project_form_submit').click

      # WHEN: user goes directly to the project page
      @browser.goto "http://localhost:9000/project/#{USERNAME}/#{PROJECT_NAME}"

      # THEN: they should see the project details
      _(@browser.h2.text).must_include USERNAME
      _(@browser.h2.text).must_include PROJECT_NAME

      contributor_columns = @browser.table(id: 'contribution_table').thead.ths.select do |col|
        col.attribute(:class).split.sort == %w[contributor username]
      end

      _(contributor_columns.count).must_equal 3
      _(contributor_columns.map(&:text).sort)
        .must_equal ['SOA-KunLin', 'Yuan Yu', 'luyimin']

      folder_rows = @browser.table(id: 'contribution_table').trs.select do |row|
        row.td(class: %w[folder name]).present?
      end
      _(folder_rows.count).must_equal 10

      file_rows = @browser.table(id: 'contribution_table').trs.select do |row|
        row.td(class: %w[file name]).present?
      end
      _(file_rows.count).must_equal 2
    end

    it '(HAPPY) should be able to traverse to subfolders' do
      # GIVEN: user has created a project
      @browser.goto homepage
      good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
      @browser.text_field(id: 'url_input').set(good_url)
      @browser.button(id: 'project_form_submit').click

      # WHEN: they go to the project's page
      @browser.goto "http://localhost:9000/project/#{USERNAME}/#{PROJECT_NAME}"

      # THEN: they should see the project and contribution details
      folder_rows = @browser.table(id: 'contribution_table').trs.select do |row|
        row.td(class: %w[folder name]).present?
      end

      views_folder = folder_rows.first.tds.find do |column|
        column.link.href.include? 'views_objects'
      end

      views_folder.link.click

      _(@browser.h2.text).must_include USERNAME
      _(@browser.h2.text).must_include PROJECT_NAME

      folder_rows = @browser.table(id: 'contribution_table').trs.select do |row|
        row.td(class: %w[folder name]).present?
      end

      file_rows = @browser.table(id: 'contribution_table').trs.select do |row|
        row.td(class: %w[file name]).present?
      end

      _(folder_rows).must_be_empty
      _(file_rows.count).must_equal 5
    end

    it '(BAD) should report error if subfolder does not exist' do
      # GIVEN: user has created a project
      @browser.goto homepage
      good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
      @browser.text_field(id: 'url_input').set(good_url)
      @browser.button(id: 'project_form_submit').click

      # WHEN user goes to a non-existent folder of the project
      @browser.goto "http://localhost:9000/project/#{USERNAME}/#{PROJECT_NAME}/bad_folder"

      # THEN: user should see a warning message
      _(@browser.div(id: 'flash_bar_danger').present?).must_equal true
      _(@browser.div(id: 'flash_bar_danger').text.downcase).must_include 'could not find'
    end

    it '(HAPPY) should report an error if project not requested' do
      # GIVEN: user has not requested a project yet, even though it exists
      project = CodePraise::Github::ProjectMapper
        .new(GITHUB_TOKEN)
        .find(USERNAME, PROJECT_NAME)
      CodePraise::Repository::For.entity(project).create(project)

      # WHEN: they go directly to the project's page
      @browser.goto "http://localhost:9000/project/#{USERNAME}/#{PROJECT_NAME}"

      # THEN: they should should find themselves back on the homepage
      _(@browser.url).must_equal(homepage + '/')

      # with a warning message
      _(@browser.div(id: 'flash_bar_danger').present?).must_equal true
      _(@browser.div(id: 'flash_bar_danger').text.downcase).must_include 'please request'
    end
  end
end
