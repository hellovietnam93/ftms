threads_count_min = ENV.fetch("RAILS_MIN_THREADS") {1}.to_i || 1
threads_count_max = ENV.fetch("RAILS_MAX_THREADS") {6}.to_i || 6
threads threads_count_min, threads_count_max
port ENV.fetch("PORT") {3000} || 3333

environment ENV.fetch("RAILS_ENV") {"development"}
workers ENV.fetch("WEB_CONCURRENCY") {2} || 2
plugin :tmp_restart

app_dir = File.expand_path("../..", __FILE__)
shared_tmp_dir = "#{app_dir}/shared/tmp"

# Default to production
rails_env = ENV["RAILS_ENV"] || "production"
environment rails_env

# Set up socket location
bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end
