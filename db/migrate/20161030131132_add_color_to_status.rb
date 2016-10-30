class AddColorToStatus < ActiveRecord::Migration[5.0]
  def change
    add_column :statuses, :color, :string
  end
end
