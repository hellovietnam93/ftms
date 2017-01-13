require "json"

namespace :db do
  desc "Back up v1.1.2 before update to v1.2.1"

  task back_up_v_1_1_2: :environment do
    Rake::Task['db:back_up_user_course'].invoke
    Rake::Task['db:back_up_user_task'].invoke
  end

  task back_up_user_course: :environment do
    path = "/tmp/user_course_type.txt"
    if !File.exists?(File.expand_path path)
      puts "Backup data user_course..."
      content = UserCourse.pluck :id, :active
      str = JSON.dump(content)
      File.open(path, "w+") {|f| f.write(str)}
    else
      puts "File already exists!"
    end
  end

  task back_up_user_task: :environment do
    path = "/tmp/user_task_status.txt"
    if !File.exists?(File.expand_path path)
      puts "Backup data user_task..."
      content = UserTaskHistory.pluck :user_task_id, :status
      str = JSON.dump(content)
      File.open(path, "w+") {|f| f.write(str)}
    else
      puts "File already exists!"
    end
  end
end
