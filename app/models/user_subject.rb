class UserSubject < ApplicationRecord
  include PublicActivity::Model
  acts_as_paranoid

  ATTRIBUTES_PARAMS = [:start_date, :end_date]

  belongs_to :user
  belongs_to :course
  belongs_to :user_course
  belongs_to :course_subject
  has_many :user_tasks, dependent: :destroy
  has_many :notifications, as: :trackable, dependent: :destroy
  has_many :activities, as: :trackable, class_name: "PublicActivity::Activity", dependent: :destroy

  after_create :create_user_tasks

  scope :load_user_subject, ->(user_id, course_id){where "user_id = ? AND course_id = ?", user_id, course_id}
  scope :load_users, ->status {where status: status}
  scope :not_finish, -> user_subjects {where.not(id: user_subjects)}
  scope :sort_by_course_subject, ->{joins(:course_subject).order("course_subjects.order asc")}
  scope :order_by_course_subject , ->{joins(:course_subject).order "course_subjects.row_order"}

  scope :load_by_course_subject, ->course_subject_ids, trainer_id do
    order_by_course_subject.joins(:user).where("course_subjects.id in (?)
      AND user_subjects.status = ? AND users.trainer_id = ?", course_subject_ids,
      UserSubject.statuses[:progress], trainer_id).includes :user
  end

  accepts_nested_attributes_for :user_tasks

  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :name, :id, :description, to: :subject, prefix: true, allow_nil: true
  delegate :name, to: :course, prefix: true, allow_nil: true

  enum status: [:init, :progress, :finish, :waiting]

  def load_trainers
    course.users.trainers
  end

  def load_trainees
    course.users.trainees
  end

  class << self
    def update_all_status status, current_user, course_subject
      load_users(statuses[:init]).each do |user_subject|
        user_subject.update_attributes status: statuses[:progress],
          start_date: Time.now, current_progress: user_subject.in_progress?,
          end_date: Time.now + course_subject.subject_during_time.days
      end
      if status == "start"
        key = "user_subject.start_all_subject"
      else
        load_users(statuses[:waiting, :progress]).each do |user_subject|
          user_subject.update_attributes  status: statuses[:finish],
          user_end_date: Time.now, current_progress: user_subject.in_progress?
        end
        key = "user_subject.finish_all_subject"
      end
      course_subject.create_activity key: key,
        owner: current_user, recipient: course_subject.course
    end
  end

  def update_status current_user, status
    if init?
      update_attributes status: :progress, start_date: Time.now,
        end_date: during_time.business_days.from_now, current_progress: in_progress?
      key = "user_subject.start_subject"
      notification_key = Notification.keys[:start]
    else
      if is_of_user? current_user
        update_attributes status: :waiting
        key = "user_subject.request_subject"
        notification_key = Notification.keys[:request]
      elsif status == Settings.subject_status.reject
        update_attributes status: :progress
        key = "user_subject.reject_finish_subject"
        notification_key = Notification.keys[:reject]
      elsif status == Settings.subject_status.finish
        update_attributes status: :finish, user_end_date: Time.now
        key = "user_subject.finish_subject"
        notification_key = Notification.keys[:finish]
      elsif status == Settings.subject_status.reopen
        update_attributes status: :progress, user_end_date: nil, current_progress: in_progress?
        key = "user_subject.reopen_subject"
        notification_key = Notification.keys[:reopen]
      end
    end
    create_activity key: key, owner: current_user, recipient: user
    if is_of_user? current_user
      CourseNotificationBroadCastJob.perform_now course,
        notification_key, current_user.id, self
    else
      UserSubjectNotificationBroadCastJob.perform_now self,
        notification_key, current_user.id
    end
  end

  def subject
    self.course_subject.subject
  end

  def name
    course_subject.subject_name
  end

  def description
    course_subject.subject.description
  end

  def content
    course_subject.subject.content
  end

  def image_url
    course_subject.image_url
  end

  def is_of_user? user
    self.user == user
  end

  def percent_progress
    if start_date.present?
      return 0 if start_date > Time.zone.today
      current_date = user_end_date
      current_date ||= Time.zone.today

      real_duration_time = end_date - start_date
      return 100 if real_duration_time <= 0

      user_current_time = (current_date - start_date).to_f
      percent = user_current_time * 100 / real_duration_time.to_f
      [percent, 100].min
    end
  end

  def create_user_task_if_create_task task
    UserTask.create task: task, user: self.user, user_subject: self
  end

  def in_progress?
    user.user_subjects.update_all current_progress: false
    true
  end

  private
  def create_user_tasks
    course_subject.tasks.each do |task|
      UserTask.find_or_create_by(user_subject_id: id,
        user_id: user_course.user_id, task_id: task.id)
    end
  end
end
