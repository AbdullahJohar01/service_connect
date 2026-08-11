class CreateAvailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :availabilities do |t|
      t.references :provider_profile, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
