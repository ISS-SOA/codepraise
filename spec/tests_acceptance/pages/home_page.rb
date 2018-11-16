# frozen_string_literal: true

# Page object for home page
class HomePage
  include PageObject

  page_url CodePraise::App.config.APP_HOST

  div(:warning_message, id: 'flash_bar_danger')
  div(:success_message, id: 'flash_bar_success')

  h1(:title_heading, id: 'main_header')
  text_field(:url_input, id: 'url_input')
  button(:add_button, id: 'project_form_submit')
  table(:projects_table, id: 'projects_table')

  indexed_property(
    :projects,
    [
      [:span, :owner,        { id: 'project[%s].owner' }],
      [:a,    :http_url,     { id: 'project[%s].link' }],
      [:span, :contributors, { id: 'project[%s].contributors' }]
    ]
  )

  def first_project
    projects[0]
  end

  def first_project_row
    projects_table_element.trs[1]
  end

  def first_project_delete
    first_project_row.button(id: 'project[0].delete').click
  end

  def first_project_hover
    first_project_row.hover
  end

  def first_project_highlighted?
    first_project_row.style('background-color').eql? 'rgba(0, 0, 0, 0.075)'
  end

  def num_projects
    projects_table_element.rows - 1
  end

  def add_new_project(remote_url)
    self.url_input = remote_url
    self.add_button
  end

  def listed_project(project)
    {
      owner: project.owner,
      name: project.name_link_element.text,
      remote_url: project.remote_url_element.text,
      num_contributors: project.contributors.split(',').count
    }
  end
end
