class UserTasksController < ApplicationController
  before_action :load_user_task
  before_action :authorize_user_task

  def update
    new_status = params[:status]
    pull_request = pull_request_url || @user_task.pull_request_url
    user_task_service = MailerServices::UserTaskService.new user_task: @user_task,
      status: new_status, pull_request_url: pull_request
    @old_status = @user_task.status
    if new_status == Settings.status.finished
      @user_task_history = user_task_service.perform
      if @user_task.update_attributes status: Settings.status.finished
        flash.now[:success] = flash_message "updated"
      else
        flash.now[:error] = flash_message "not_updated"
      end
    else
      if user_task_service.perform
        @user_task.update_attributes pull_request_url: pull_request
        room_id = @user_task.user_subject.course_subject.chatwork_room_id
        trainer = current_user.trainer
        send_chatwork = @user_task.send_message_chatwork users: [current_user, trainer],
          message: pull_request, room_id: room_id
        if send_chatwork
          flash.now[:success] = flash_message "updated"
        else
          flass.now[:error] = flash_message "not_updated"
        end
      else
        flash.now[:error] = flash_message "not_updated"
      end
    end
    track_activity
    load_data
    respond_to do |format|
      format.js
    end
  end

  private
  def track_activity
    new_status = @user_task.status
    unless @old_status == new_status
      @user_task.create_activity key: "user_task.change_status",
        owner: current_user, parameters: {old_status: @old_status,
        new_status: new_status}
    end
  end

  def load_data
    @subject_supports = Supports::SubjectTrainee.new subject: @user_task
      .user_subject.subject, user_course_id: @user_task.user_subject
      .user_course_id
  end

  def authorize_user_task
    authorize_with_multiple page_params.merge(record: @user_task), UserTaskPolicy
  end

  def pull_request_url
    params.fetch(:user_task, {}).permit(:pull_request_url)[:pull_request_url]
  end
end
