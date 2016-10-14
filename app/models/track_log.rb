class TrackLog < ApplicationRecord
  belongs_to :user

  scope :order_by_time, ->{order "created_at DESC"}
end
