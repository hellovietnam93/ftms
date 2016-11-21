namespace :db do
  task create_test_permission: :environment do
    puts "Creating Function"

    trainer_permissions = {
      Answer: ["show", "index","edit", "update"],
      Exam: ["show", "index","edit", "update"],
      Question: ["show", "index","edit", "update"],
      Result: ["show", "index","edit", "update"]
    }

    trainee_permissions = {
      Answer: ["show", "index"],
      Exam: ["show", "index"],
      Question: ["show", "index"],
      Result: ["show", "index","edit", "update"]
    }

    trainer_permissions.each do |permission|
      permission[1].each do |action|
        function = Function.create! model_class: permission[0], action: action
        RoleFunction.create! role_id: 2, function_id: function.id
      end
    end

    trainee_permissions.each do |permission|
      permission[1].each do |action|
        function = Function.create! model_class: permission[0], action: action
        RoleFunction.create! role_id: 3, function_id: function.id
      end
    end
  end
end
