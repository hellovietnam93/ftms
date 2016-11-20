class Admin::TrainingManagementsController < ApplicationController
  include FilterData
  before_action :authorize
  before_action :load_filter, only: :index

  def index
    add_breadcrumb_index "training_managements"
    users = Trainee.includes(:trainer, :notes, user_subjects: [:course_subject],
      profile: [:status, :user_type, :location, :university, :programming_language]).order :name
    @training_management_presenters = TrainingManagementPresenter.new(users, @namespace).render
  end
end
