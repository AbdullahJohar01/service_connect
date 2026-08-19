class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :label
      t.string :street
      t.string :city
      t.string :postal_code
      t.decimal :latitude
      t.decimal :longitude
      t.boolean :is_default

      t.timestamps
    end
  end
end
