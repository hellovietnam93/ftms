class Admin::UserCoursesController < ApplicationController
  before_action :find_user_course, :authorize, only: :update

  def update
    if @user_course.update_attributes status: params[:status]
      flash.now[:success] = flash_message "updated"
    else
      flash.now[:error] = flash_message "not_updated"
    end
    respond_to do |format|
      format.js
    end
  end

  private
  def find_user_course
    @user_course = UserCourse.find_by id: params[:id]
    unless @user_course
      flash[:alert] = flash_message "not_find"
      redirect_to [:admin, @user_course.course]
    end
  end
end
