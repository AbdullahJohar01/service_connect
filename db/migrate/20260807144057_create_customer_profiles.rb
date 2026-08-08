class CreateCustomerProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date_of_birth
      t.string :preferred_language

      t.timestamps
    end
  end
end
