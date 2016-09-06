# config valid only for current version of Capistrano
lock "3.6.0"

set :application, "tms"
set :repo_url, "git@github.com:framgia/ftms.git"
set :rails_env, "production"
set :user_name, "mai.tuan.viet"
set :application_name, "#{fetch :application}_#{fetch :rails_env}"
set :keep_releases, 3
set :chmod755, "app config db lib public"
set :use_sudo, false
set :branch, "develop"# `git rev-parse --abbrev-ref HEAD`.chomp
set :deploy_to, "/var/www/#{fetch :application_name}"
set :linked_dirs, fetch(:linked_dirs, []).push("log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", "public/system", "public/uploads")
set :linked_files, fetch(:linked_files, []).push("config/database.yml", "config/secrets.yml")

role :web, "10.0.1.30", primary: true
role :db, "10.0.1.30", primary: true

namespace :deploy do
  before :deploy, "db:config_db"
end

namespace :db do
  set :db_username, "root"
  set :db_password, 123456

  desc "Create database yaml in shared path"
  task :config_db do
    on roles(:all) do |h|
      file = "#{shared_path}/config/database.yml"

      if test("[ -f #{file} ]")
        info "#{file} already exists on #{h}!"
      else
        db_config = <<-EOF
base: &base
  adapter: mysql2
  encoding: utf8
  reconnect: false
  pool: 5
  username: #{fetch :db_username}
  password: #{fetch :db_password}
development:
  database: #{fetch :application}_development
  <<: *base
test:
  database: #{fetch :application}_test
  <<: *base
production:
  database: #{fetch :application}_production
  <<: *base
EOF

        execute :mkdir, "-p #{shared_path}/config"
        execute :touch, file
        execute :echo, "\"#{db_config}\" > #{file}"
      end
    end
  end

  desc "remake database"
  task :remake do
    on roles(:all) do |h|
      execute "cd #{current_path} && ~/.rvm/bin/rvm default do bundle exec rake db:remake RAILS_ENV=#{fetch :stage}"
    end
  end
end

namespace :log do
  desc "Get production log"
  task :t do
    on roles(:app) do
      execute :tail, "-f #{shared_path}/log/#{fetch :rails_env}.log"
    end
  end
end
