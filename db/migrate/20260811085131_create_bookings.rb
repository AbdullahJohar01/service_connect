class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :provider, null: false, foreign_key: { to_table: :provider_profiles }
      t.references :service_category, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true

      t.datetime :scheduled_at
      t.integer :estimated_duration
      t.text :customer_description
      t.text :provider_notes
      t.integer :status
      t.decimal :estimated_price
      t.decimal :final_price
      t.text :cancellation_reason
      t.datetime :accepted_at
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :cancelled_at

      t.timestamps
    end
  end
end
