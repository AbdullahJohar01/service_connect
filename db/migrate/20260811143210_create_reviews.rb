class CreateReviews < ActiveRecord::Migration[8.1]
def change
create_table :reviews do |t|
t.references :customer, null: false, foreign_key: { to_table: :users }
t.references :provider, null: false, foreign_key: { to_table: :provider_profiles }
t.references :booking, null: false, foreign_key: true
t.integer :rating, null: false
t.text :comment

  t.timestamps
end
end
end
