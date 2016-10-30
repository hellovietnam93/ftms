class Status < ApplicationRecord
  acts_as_paranoid

  ATTRIBUTES_PARAMS = [:name, :color]

  has_many :profiles

  validates :name, presence: true
end
