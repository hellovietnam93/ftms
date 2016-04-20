namespace :db do
  desc "remake database data"
  task remake_data: :environment do
    Rake::Task["db:migrate:reset"].invoke

    puts "Creating Role"
    ["admin", "trainer"].each do |name|
      Fabricate :role, name: name, allow_access_admin: true
    end
    Fabricate :role, name: "trainee", allow_access_admin: false

    puts "Creating User"
    Fabricate :user, email: "admin@tms.com", role_id: 1
    Fabricate :user, email: "supervisor@tms.com", role_id: 2
    30.times do
      Fabricate :user
    end

    # puts "Creating Subject"
    # 10.times do
    #   Fabricate :subject
    # end

    puts "Creating Evaluation Template"
    5.times do
      Fabricate :evaluation_template
    end

    # puts "Creating Task Master"
    # 5.times do
    #   Fabricate :task_master
    # end

    puts "Creating Permissions"
    Fabricate :permission, model_class: "CourseMaster", role_id: 1
    ["Course", "CourseSubject", "Subject", "UserSubject"].each do |name|
      Fabricate :permission, model_class: name, action: "manage", role_id: 2
    end
    ["Course", "CourseSubject", "UserCourse", "Subject", "UserSubject", "Task",
      "UserTask", "User"].each do |name|
      Fabricate :permission, model_class: name, action: "read", role_id: 3
    end
    Fabricate :permission, model_class: "Task", action: "create"
    ["UserTask", "User"].each do |name|
      Fabricate :permission, model_class: name, action: "update", role_id: 3
    end

    puts "Create Rank"
    5.times do
      Fabricate :rank
    end

    puts "Create Universities"
    ["Vietnam National University, Hanoi", "Hanoi University of Science and Technology",
      "Foreign Trade University", "Hanoi University of Industry"].each do |name|
      Fabricate :university, name: name
    end

    puts "Create Programming Languages"
    ["Ruby", "PHP", "Android", "Java", "C"].each do |name|
      Fabricate :programming_language, name: name
    end

    puts "Create User Types"
    ["Intern", "VPG", "JPG", "New dev", "Tester"].each do |name|
      Fabricate :user_type, name: name
    end

    puts "Create User Progresses"
    ["Tutorial", "Project demo", "Project 1", "Project 2", "Git"].each do |name|
      Fabricate :user_progress, name: name
    end

    puts "Create Status"
    ["Inprogress", "Finish", "Prepare project", "Jointed project"].each do |name|
      Fabricate :status, name: name
    end
  end
end
