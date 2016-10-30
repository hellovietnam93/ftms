class TrainingManagementPresenter < ActionView::Base
  include Rails.application.routes.url_helpers

  def initialize users, namespace
    @users = users
    @namespace = namespace
  end

  def render
    sidebar = Array.new
    body = Array.new
    @users.each_with_index do |user, index|
      sidebar << sidebar_item(user, index)
      body << body_item(user, index)
    end
    html = "<aside id=\"parent\" class=\"fixedTable-sidebar\">
      <div id=\"child\">
        <div id=\"table-sidebar\">
          <div class=\"tbody listsort filter_table_left_part\" id=\"list-records\">
    "
    html += sidebar.join("")
    html += "</div></div></div></aside>"

    html += "<div class=\"fixedTable-body tabel-scroll\">
      <div class=\"tbody listsort filter_table_right_part\">"
    html += body.join("")
    html += "</div></div>"
  end

  private
  def sidebar_item user, index
    "<div class=\"trow list_#{index}\" id=\"sidebar-row-#{user.id}\" style=\"background: #{user.profile.status.color if user.profile.status};\">
      <div class=\"tcell stt\">#</div>
      <div class=\"tcell name trainee_name\" title=\"#{user.name}\">
      #{link_to user.name, eval("#{@namespace}_user_path(user)")}
      </div>
    </div>
    "
  end

  def body_item user, index
    html = "<div class=\"trow #{"list_#{index}" }\" id=\"body-row-#{user.id}\" style=\"background: #{user.profile.status.color if user.profile.status};\">
      <div class=\"tcell trainee_type\" title=\"#{user.profile.user_type_name}\">
        #{user.profile.user_type_name}
      </div>
      <div class=\"tcell location\" title=\"#{user.profile.location_name}\">
        #{user.profile.location_name}
      </div>
      <div class=\"tcell trainee_status\" title=\"#{user.profile.status_name}\">
        #{user.profile.status_name}
      </div>
      <div class=\"tcell university\" title=\"#{user.profile.university_name}\">
        #{user.profile.university_name}
      </div>
      <div class=\"tcell graduation\">
      #{l user.profile_graduation, format: :year_month if user.profile_graduation}
      </div>
      <div class=\"tcell programming_language\" title=\"#{user.profile.programming_language_name}\">
        #{user.profile.programming_language_name}
      </div>
      <div class=\"tcell start_training_date text-right\">
        #{l user.profile.start_training_date, format: :default if user.profile.start_training_date}
      </div>
      <div class=\"tcell leave_date text-right\">
        #{l user.profile.leave_date, format: :default if user.profile.leave_date}
      </div>
      <div class=\"tcell finish_training_date text-right\">
        #{l user.profile.finish_training_date, format: :default if user.profile.finish_training_date}
      </div>
      <div class=\"tcell ready_for_project\">
        #{user.profile.ready_for_project? ? t("profiles.columns.ready_for_project.ready") :
          t("profiles.columns.ready_for_project.not_ready")}
      </div>
      <div class=\"tcell contract_date text-right\">
        #{l user.profile.contract_date, format: :default if user.profile.contract_date}
      </div>
      <div class=\"tcell working_day text-right\" title=\"#{user.profile_working_day}\">
        #{user.profile_working_day}
      </div>
      <div class=\"tcell trainer\" title=\"#{user.trainer.name if user.trainer}\">
        #{link_to user.trainer.name, eval("#{@namespace}_user_path(user.trainer)") if user.trainer}
      </div>
      <div class=\"tcell current_progress\" title=\"#{user.current_progress.name if user.current_progress}\">
        #{user.current_progress.name if user.current_progress}
      </div>
      <div class=\"tcell note\">
        #{user.notes.any? ? user.notes.last.name : ""}
      </div>"
    html += "<div class=\"tcell action\">
      #{link_to t("buttons.edit"), eval("edit_#{@namespace}_user_path(user)")}
      </div></div>"
  end
end
