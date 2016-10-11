module UsersMailerHelper

  def load_user_task_histories course_id
    UserTaskHistory.all_user_task_history course_id
  end
end
