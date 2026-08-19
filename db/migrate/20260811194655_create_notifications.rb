class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :booking, null: false, foreign_key: true
      t.string :notification_type, null: false
      t.text :message, null: false
      t.boolean :read, null: false, default: false

      t.timestamps
    end
  end
end
