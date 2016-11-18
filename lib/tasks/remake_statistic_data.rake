namespace :db do
  desc "Add data to table statistics"
  task remake_statistic_data: :environment do
    puts "Find all stage"
    Stage.all.each do |stage|
      instance_variable_set("@#{stage.name.downcase.gsub(" ", "_")}", stage)
    end

    puts "Remove all available statistics"
    Statistic.delete_all

    puts "Add data to table statistics"
    Profile.includes(:user_type, :programming_language, :location, :stage).each do |profile|
      UserType.all.each do |user_type|
        ProgrammingLanguage.all.each do |programming_language|
          Location.all.each do |location|
            if profile.start_training_date
              statistic = Statistic.find_or_initialize_by month: profile.start_training_date.to_date.beginning_of_month,
                user_type: user_type, programming_language: programming_language,
                location: location, stage: @in_education
              statistic.save
              if profile.user_type == user_type && profile.programming_language == programming_language &&
                profile.stage == @in_education && profile.location == location
                statistic.total_trainee += 1
                statistic.save
              end
            elsif profile.leave_date
              statistic = Statistic.find_or_initialize_by month: profile.leave_date.to_date.beginning_of_month,
                user_type: user_type, programming_language: programming_language,
                location: location, stage: @resigned
              statistic.save
              if profile.user_type == user_type && profile.programming_language == programming_language &&
                profile.stage == @resigned && profile.location == location
                statistic.total_trainee += 1
                statistic.save
              end
            elsif profile.join_div_date
              statistic = Statistic.find_or_initialize_by month: profile.join_div_date.to_date.beginning_of_month,
                user_type: user_type, programming_language: programming_language,
                location: location, stage: @joined_div
              statistic.save
              if profile.user_type == user_type && profile.programming_language == programming_language &&
                profile.stage == @joined_div && profile.location == location
                statistic.total_trainee += 1
                statistic.save
              end
            end
          end
        end
      end
    end
    puts "Finish add data to table statistics"
  end
end
