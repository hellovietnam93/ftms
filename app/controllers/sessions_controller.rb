class SessionsController < Devise::SessionsController
  after_action :log_sign_in, only: :create
  before_action :log_sign_out, only: :destroy

  private
  def log_sign_in
    current_user.track_logs.create signin_time: Time.zone.now, signin_ip: request.remote_ip
  end

  def log_sign_out
    log = current_user.track_logs.order_by_time.first
    log.update_attributes(signout_time: Time.zone.now) if log.signout_time.nil?
  end
end
