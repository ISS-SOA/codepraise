# frozen_string_literal: true

# Page object for home page
class ProjectPage
  include PageObject

  page_url CodePraise::App.config.APP_HOST +
           '/project/<%=params[:owner_name]%>/<%=params[:project_name]%>' \
           '<%=params[:folder] ? "/#{params[:folder]}" : ""%>'

  div(:warning_message, id: 'flash_bar_danger')
  div(:success_message, id: 'flash_bar_success')

  h2(:project_title, id: 'project_fullname')
  span(:ownername, id: 'project.owner')
  table(:contribution_table, id: 'contribution_table')

  indexed_property(
    :contributors,
    [
      [:span, :username, { id: 'contributor.username' }]
    ]
  )

  def folders
    contribution_table_element.trs(id: 'folder_row')
  end

  def folder_called(folder_name)
    folders.find { |folder| folder.td(id: 'folder.name').text.eql? folder_name }
  end

  def files
    contribution_table_element.trs(id: 'file_row')
  end
end
