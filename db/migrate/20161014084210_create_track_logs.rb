class CreateTrackLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :track_logs do |t|
      t.datetime :signin_time
      t.string :signin_ip
      t.datetime :signout_time
      t.references :user

      t.timestamps
    end
  end
end
