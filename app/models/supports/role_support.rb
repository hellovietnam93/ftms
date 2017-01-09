class Supports::RoleSupport
  attr_reader :role

  def initialize role
    @role = role
  end

  def presenter form
    @role_allocate_function_presenters_admin ||= AllocateFunctionPresenter.new(routes_admin: admin_routes,
      routes_trainer: trainer_routes, routes_trainee: trainee_routes,
      namespace: @namespace, role: @role, form: form).render
  end

  private
  def functions
    @functions ||= Function.all
  end

  def trainee_functions
    @trainee_functions ||= functions.reject{|route| route.model_class.include?("admin") || route.model_class.include?("trainer")}
  end

  def admin_functions
    @admin_functions ||= functions.select{|route| route.model_class.include?("admin")}
  end

  def trainer_functions
    @trainer_functions ||= functions.select{|route| route.model_class.include?("trainer")}
  end

  ["trainer", "trainee", "admin"].each do |type|
    define_method "#{type}_routes" do
      routes = []
      send("#{type}_functions").map(&:model_class).uniq.each do |controller|
        routes << Hash[:controller, controller, :actions,
          send("#{type}_functions").select {|function| function.model_class == controller}.pluck(:action).uniq]
      end
      routes
    end
  end
end
