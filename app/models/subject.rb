class Subject < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  has_many :task_masters, dependent: :destroy
  has_many :course_subjects, dependent: :destroy
  has_many :courses, through: :course_subjects

  validates :name, presence: true, uniqueness: true

  scope :subject_not_start_course, ->course{where "id NOT IN (SELECT subject_id
    FROM course_subjects WHERE course_id = ? AND status <> 0)", course.id}

  scope :recent, ->{order created_at: :desc}

  accepts_nested_attributes_for :task_masters, allow_destroy: true,
    reject_if: proc {|attributes| attributes[:name].blank?}

  SUBJECT_ATTRIBUTES_PARAMS = [:name, :description, :content, :image, :during_time,
    task_masters_attributes: [:id, :name, :description, :content, :image, :_destroy]]

end
