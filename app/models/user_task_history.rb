class UserTaskHistory < ApplicationRecord
  acts_as_paranoid

  belongs_to :user_task

  enum status: [:init, :continue, :finished]
  scope :all_user_task_history, ->course_id{
    joins(user_task: [user_subject: :course]).
    where("date(user_task_histories.created_at) = '#{Date.today}'
    AND course_id = ?", course_id).order("user_tasks.user_id,
    user_tasks.user_subject_id, user_task_histories.status")}
end
