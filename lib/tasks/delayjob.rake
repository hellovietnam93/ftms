namespace :delayjob do
  desc "TODO"
  task mailday: :environment do
    User.trainers.each do |trainer|
      if trainer.courses.any?
        MailByDayJob.perform_now MailByDayJob::MAIL_DAY, trainer.id
      end
    end
  end
end
