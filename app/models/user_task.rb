class UserTask < ApplicationRecord
  acts_as_paranoid
  include PublicActivity::Model

  has_many :activities, as: :trackable, class_name: "PublicActivity::Activity",
    dependent: :destroy
  has_many :user_task_histories, dependent: :destroy

  belongs_to :task
  belongs_to :user_subject
  belongs_to :user

  delegate :id, :name, :image_url, :description, to: :task, prefix: true, allow_nil: true
  delegate :name, :id, to: :user, prefix: true, allow_nil: true
  delegate :description, to: :task, prefix: true, allow_nil: true

  scope :user_task_of_subject_progress,
    -> {joins(:user_subject).where "user_subjects.status = ?",
      UserSubject.statuses[:progress]}
  scope :user_finished_task_in_day, ->course_id{joins(user_subject: :course).includes(:task, :user, :user_subject)
    .where("user_tasks.status = #{statuses[:finished]} AND
    date(user_tasks.updated_at) = '#{Date.today}' AND course_id = ? ",
    course_id).order(:user_id, :user_subject_id)}

  enum status: [:in_progress, :finished]

  def nil_master?
    task.task_master_id.nil?
  end

  def create_by_trainee?
    task.create_by_trainee
  end

  def subject_in_progress?
    user_subject.progress?
  end
end
