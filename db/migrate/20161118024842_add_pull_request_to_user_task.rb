class AddPullRequestToUserTask < ActiveRecord::Migration[5.0]
  def change
    add_column :user_tasks, :pull_request_url, :string
    add_column :user_task_histories, :pull_request_url, :string
  end
end
