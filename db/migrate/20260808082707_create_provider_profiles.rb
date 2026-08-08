class CreateProviderProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :provider_profiles do |t|
      t.references :user, null: false, foreign_key: true

      t.string :business_name, null: false
      t.text :description
      t.integer :experience_years, default: 0
      t.decimal :hourly_rate, precision: 10, scale: 2

      t.integer :approval_status, default: 0, null: false
      t.decimal :average_rating, precision: 3, scale: 2, default: 0
      t.integer :total_reviews, default: 0

      t.timestamps
    end
  end
end
