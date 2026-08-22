class AddActivityLogsAndBookingIntegrity < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs do |t|
      t.references :actor, foreign_key: { to_table: :users }, null: true
      t.references :subject, polymorphic: true, null: true
      t.string :action, null: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :activity_logs, :action
    add_index :bookings, [ :provider_id, :scheduled_at ]
    remove_index :reviews, :booking_id
    add_index :reviews, :booking_id, unique: true
    add_column :provider_profiles, :rejection_reason, :text
  end
end
