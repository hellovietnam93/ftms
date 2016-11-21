class MailerServices::UserTaskService
  attr_reader :args

  def initialize args
    @user_task = args[:user_task]
    @status = args[:status]
    @pull_request_url = args[:pull_request_url]
  end

  def perform
    user_task_history = @user_task.user_task_histories.create status: @status,
      pull_request_url: @pull_request_url
  end
end
