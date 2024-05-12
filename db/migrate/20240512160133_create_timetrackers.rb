class CreateTimetrackers < ActiveRecord::Migration[7.0]
  def change
    create_table :timetrackers do |t|
      t.integer :user_id
      t.string :domain
      t.integer :tracked_minute
      t.integer :tracked_seconds

      t.timestamps
    end
  end
end
