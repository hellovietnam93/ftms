class Admin::AssignTrainersController < ApplicationController
  authorize_resource :course, class: false
  before_action :find_course, only: [:edit, :update]

  def edit
    @supports = Supports::Course.new @course
    add_breadcrumb_path "courses"
    add_breadcrumb @course.name, admin_course_path(@course)
    add_breadcrumb t "courses.assign_trainers"
  end

  def update
    if params[:course] && @course.update_attributes(course_params)
      flash[:success] = flash_message "updated"
    else
      flash[:danger] = flash_message "not_updated"
    end
    redirect_to admin_course_path @course
  end

  private
  def course_params
    params.require(:course).permit Course::USER_COURSE_ATTRIBUTES_PARAMS
  end

  def find_course
    @course = Course.includes(user_courses: :user).find_by_id params[:course_id]
    if @course.nil?
      flash[:alert] = flash_message "not_find"
      redirect_to admin_courses_path
    end
  end
end
