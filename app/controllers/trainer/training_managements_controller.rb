class Trainer::TrainingManagementsController < ApplicationController
  before_action :verify_trainer

  include FilterData

  before_action :load_filter, only: :index

  def index
    add_breadcrumb_index "training_managements"
    users = User.trainees.includes(:trainer, user_subjects: [:course_subject],
      profile: [:status, :user_type, :location, :university, :programming_language, :stage]).order :name
    @training_management_presenters = TrainingManagementPresenter.new(users, @namespace).render
  end

  private
  include VerifyTrainer
end
