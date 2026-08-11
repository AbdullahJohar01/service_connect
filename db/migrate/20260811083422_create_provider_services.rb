class CreateProviderServices < ActiveRecord::Migration[8.1]
  def change
    create_table :provider_services do |t|
      t.references :provider_profile, null: false, foreign_key: true
      t.references :service_category, null: false, foreign_key: true
      t.text :description
      t.decimal :base_price, null: false
      t.integer :duration_minutes, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
