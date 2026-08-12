class CreateBookingStatusHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_status_histories do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :changed_by, null: false, foreign_key: { to_table: :users }

      t.integer :previous_status
      t.integer :new_status, null: false
      t.text :notes

      t.timestamps
    end
  end
end
