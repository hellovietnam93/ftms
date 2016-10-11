env :PATH, ENV["PATH"]

every :day, at: "11:55 pm" do
  command "backup perform --trigger fts_backup", output: "log/daily.log"
end

every :day, at: "11:55 pm" do
  rake "delayjob:mailday"
end
