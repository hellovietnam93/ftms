class CourseDecorator < Draper::Decorator
  delegate_all
  include ApplicationHelper, UsersMailerHelper

  def set_status
    "<span class='label-status #{set_background_color_status course.status}'>
      #{I18n.t "courses.labels.status.#{self.status}"}</span>".html_safe
  end

  def show_user_action number
    show_html = "<div>#{number}: #{I18n.t 'mail.by_day.course',
      name: self.name}</div><table style='width: 100%;'>
      <tr>
        <td style='font-weight: bold; width: 10%;'>
          #{I18n.t 'mail.by_day.name'}</td>
        <td style='font-weight: bold; width: 10%;'>
          #{I18n.t 'mail.by_day.subject'}</td>
        <td style='font-weight: bold; width: 10%;'>
          #{I18n.t 'mail.by_day.progress'}</td>
        <td style='font-weight: bold; width: 20%;'>
          #{I18n.t 'mail.by_day.task_init'}</td>
        <td style='font-weight: bold; width: 25%;'>
          #{I18n.t 'mail.by_day.task_continue'}</td>
        <td style='font-weight: bold; width: 25%;'>
          #{I18n.t 'mail.by_day.task_finish'}</td>"
    user_task_histories = load_user_task_histories self.id
    users = self.users.trainees.to_a
    if user_task_histories.any?
      user = user_task_histories.first.user_task.user
      users.delete(user)
      subject = user_task_histories.first.user_task.user_subject.subject
      current_status = user_task_histories.first.status
      show_html += "</tr><tr>
        <td style='border: 1px solid #cecece;'>
          #{I18n.t 'mail.by_day.user_name', user_name: user.name}
        </td>
        <td style='border: 1px solid #cecece;'>
          #{I18n.t 'mail.by_day.subject_name',
          subject_name: subject.name}
        </td>
        <td style='border: 1px solid #cecece;'>
          #{I18n.t 'mail.by_day.progress_done',
          progress: user_task_histories.first.user_task.user_subject.percent_progress.to_i}
        </td>
        <td style='border: 1px solid #cecece;'>"
      user_task_histories.each do |user_task_history|
        unless user_task_history.user_task.user_id == user.id
          user = user_task_history.user_task.user
          users.delete(user)
          subject = user_task_history.user_task.user_subject.subject
          current_status = "init"
          show_html += "</td></tr><tr>
            <td style='border: 1px solid #cecece;'>
              #{I18n.t 'mail.by_day.user_name', user_name: user.name}
            </td>
            <td style='border: 1px solid #cecece;'>
              #{I18n.t 'mail.by_day.subject_name', subject_name: subject.name}
            </td>
            <td style='border: 1px solid #cecece;'>
              #{I18n.t 'mail.by_day.progress_done',
              progress: user_task_history.user_subject.percent_progress.to_i}
            </td>
            <td style='border: 1px solid #cecece;'>"
        end
        unless user_task_history.user_task.user_subject.subject_id == subject.id
          subject = user_task_history.user_task.user_subject.subject
          current_status = user_task_history.status
          show_html += "</td></tr><tr><td></td>
            <td style='border: 1px solid #cecece;'>
              #{I18n.t 'mail.by_day.subject_name',
              subject_name: subject.name}
            </td>
            <td style='border: 1px solid #cecece;'>
              #{I18n.t 'mail.by_day.progress_done',
              progress: user_task_history.user_subject.percent_progress.to_i}
            </td>
            <td style='border: 1px solid #cecece;'>"
        end
        if user_task_history.init?
          show_html += "#{I18n.t 'mail.by_day.continue_task',
            task_name: user_task_history.user_task.task_name}<br>"
          if current_status == "init"
            current_status = "continue"
          end
        elsif user_task_history.continue?
          if current_status == "continue"
            show_html += "</td><td style='border: 1px solid #cecece;'>"
            current_status = "finished"
          end
          show_html += "#{I18n.t 'mail.by_day.continue_task',
            task_name: user_task_history.user_task.task_name}<br>"
        else
          if current_status == "init"
            show_html += "</td><td style='border: 1px solid #cecece;'>
              </td><td style='border: 1px solid #cecece;'>"
          elsif current_status == "finished" || current_status == "continue"
            show_html += "</td><td style='border: 1px solid #cecece;'>"
          end
          current_status = "init"
          show_html += "#{I18n.t 'mail.by_day.finish_task',
            task_name: user_task_history.user_task.task_name}<br>"
        end
      end
    end

    show_html += "</td><td style='border: 1px solid #cecece;'></td><td style='border: 1px solid #cecece;'>" if current_status == "continue"

    unless users.blank?
      show_html += "</tr>"
      users.each do |user|
        show_html += "<tr>
          <td style='border: 1px solid #cecece;'>
            #{user.name}
          </td>
          <td style='border: 1px solid #cecece;'>
            #{user.user_subjects.progress.first.subject_name if
            user.user_subjects.progress.any?}
          </td>
          <td style='border: 1px solid #cecece;'>
            #{I18n.t 'mail.by_day.progress_done',
            progress: user.user_subjects.progress
            .first.percent_progress.to_i if
            user.user_subjects.progress.any?}
          </td>
          <td style='border: 1px solid #cecece;'>
            #{I18n.t 'mail.by_day.no_task_finish'}
          </td>
          <td style='border: 1px solid #cecece;'>
            #{I18n.t 'mail.by_day.no_task_finish'}
          </td>
          <td style='border: 1px solid #cecece;'>
            #{I18n.t 'mail.by_day.no_task_finish'}
          </td>"
      end
    end
    show_html += "</tr></table>"
    show_html.html_safe
  end
end
