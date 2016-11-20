namespace :db do
  desc "update notification data"
  task update_notifications: :environment do
    xxx = ["start", "finish", "progress", "waiting", "progres"]

    puts "Updating notification..."

    Notification.all.each do |notification|
      temp_key = notification.key_before_type_cast
      if notification.trackable_type == UserSubject.name
        if xxx[temp_key]
          notification.update_attributes key: :change_status_up, parameters: xxx[temp_key]
        end
      elsif notification.trackable_type == Course.name
        notification.update_attributes key: xxx[temp_key] == "start" ? :start_course : :finish_course
      end
    end
  end
end
