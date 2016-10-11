class CreateUserTaskHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :user_task_histories do |t|
      t.integer :status, default: 0
      t.datetime :deleted_at

      t.references :user_task, foreign_key: true

      t.timestamps
    end
    add_index :user_task_histories, :deleted_at
  end
end
