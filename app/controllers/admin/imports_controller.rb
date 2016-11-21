class Admin::ImportsController < ApplicationController
  before_action :authorize

  def index
  end

  def create
    import = Import.new params[:file]
    if import.save!
      flash[:success] = t "import_data.success"
    else
      flash[:danger] = t "import_data.error"
    end
    redirect_to admin_questions_path
  end
end
