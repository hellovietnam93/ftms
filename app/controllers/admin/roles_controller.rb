class Admin::RolesController < ApplicationController
  include FilterData
  before_action :authorize
  before_action :load_role, only: [:edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html {add_breadcrumb_index "roles"}
      format.json {
        render json: RolesDatatable.new(view_context, @namespace, current_user)
      }
    end
  end

  def new
    @role = Role.new
    @supports = Supports::RoleSupport.new @role, load_filter
    add_breadcrumb_path "roles"
    add_breadcrumb_new "roles"
  end

  def create
    @role = Role.new role_params
    if @role.save
      flash[:success] = flash_message "created"
      redirect_to admin_roles_path
    else
      flash[:failed] = flash_message "not_created"
      render :new
    end
  end

  def edit
    @supports = Supports::RoleSupport.new @role, load_filter
    add_breadcrumb_path "roles"
    add_breadcrumb @role.name
    add_breadcrumb_edit "roles"
  end

  def update
    if @role.update_attributes role_params
      add_user_function
      flash[:success] = flash_message "updated"
      redirect_to admin_roles_path
    else
      flash[:failed] = flash_message "not_update"
      render :edit
    end
  end

  def destroy
    if @role.destroy
      flash[:success] = flash_message "deleted"
    else
      flash[:failed] = flash_message "not_deleted"
    end
    redirect_to :back
  end

  private
  def role_params
    params.require(:role).permit Role::ATTRIBUTES_ROLE_PARAMS
  end

  def add_user_function
    user_functions = []
    Object.const_get(@role.role_type.classify).all.each do |user|
      user.user_functions.delete_all
      @role.functions.each do |function|
        user_functions << {user_id: user.id, function_id: function.id,
          role_type: @role.role_type_before_type_cast}
      end
    end
    UserFunction.create user_functions
  end
end
