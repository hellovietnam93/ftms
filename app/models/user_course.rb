class UserCourse < ApplicationRecord
  include PublicActivity::Model

  acts_as_paranoid

  before_save :restore_data

  belongs_to :user
  belongs_to :course

  delegate :name, :description, :start_date, :end_date, :status,
    :language, to: :course, prefix: true, allow_nil: true

  has_many :trainee_evaluations, as: :targetable

  scope :course_not_init, ->{where.not status: Course.statuses[:init]}
  scope :find_user_by_role, ->role_id{joins(trainee: :user_roles)
    .where("user_roles.role_id = ?", role_id)}

  delegate :id, :name, :email, to: :user, prefix: true, allow_nil: true
  delegate :name, to: :course, prefix: true, allow_nil: true

  enum status: [:init, :progress, :finish]

  def restore_data
    if deleted_at_changed?
      restore recursive: true
    end
  end
end
