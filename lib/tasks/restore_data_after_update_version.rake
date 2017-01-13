require "json"

namespace :db do
  desc "Restore data after update v1.1.2 to v1.2.1"

  task restore_data_v_1_1_2_to_v_1_2_1: :environment do
    Rake::Task["db:load_user_type"].invoke
    Rake::Task["db:restore_data_from_file"].invoke
    Rake::Task["db:update_user_course_type"].invoke
  end

  task load_user_type: :environment do
    ActiveRecord::Base.transaction do
      User.find_by(id: 1).update_attributes type: "Admin"
      ids = [2, 6, 8, 164, 3, 5, 12, 138, 139, 7, 4, 24, 21, 25, 135]
      User.where(id: ids).update_all type: "Trainer"
      User.where(type: nil).update_all type: "Trainee"
      puts "Update user type successful!"
    end
  end
  task restore_data_from_file: :environment do
    user_course_file_path = "/tmp/user_course_type.txt"
    if File.exists?(File.expand_path user_course_file_path)
      puts "Restore user_course's type from file"
      str = File.read user_course_file_path
      content = JSON.load str
      content.each do |arr|
        user_course = UserCourse.find_by id: arr[0]
        course = Course.find_by id: user_course.course_id
        if user_course && course
          if arr[1] == "false"
            user_course.update_attributes status: 0
          elsif arr[1] == "true"
            user_course.update_attributes status: course.finish? ? 2 : 1
          end
        end
      end
    else
      puts "File could not found!"
    end

    user_task_file_path = "/tmp/user_task_status.txt"
    if File.exists?(File.expand_path user_task_file_path)
      puts "Restore user_task's status from file"
      str = File.read user_task_file_path
      content = JSON.load str
      content.each do |user_task|
        task = UserTask.find_by id: user_task[0]
        status = case user_task[1]
          when "continue"
            2
          when "finished"
            3
          else
            0
          end
        task.try :update_attributes, status: status
      end
    else
      puts "File could not found!"
    end
  end

  task update_user_course_type: :environment do
    tmp_ntd = UserCourse.where "user_id = ? AND DATE(created_at) >= ?" , 12, "02/10/2016".to_date
    tmp_ntd.update_all type: "TrainerCourse"

    ids = [2, 6, 8, 164, 3, 5, 138, 139, 7, 4, 24, 21, 25, 135]
    trainer_courses = UserCourse.where(user_id: ids).update_all type: "TrainerCourse"
    UserCourse.where(type: nil).update_all type: "TraineeCourse"
    puts "Update user_course type complete"
  end
end
