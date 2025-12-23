class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    create_table :people do |t|
      t.string :first_name, null: false, limit: 50
      t.string :middle_name, limit: 50
      t.string :last_name, null: false, limit: 50
      t.string :ssn, null: false
      t.string :street_address_1, null: false
      t.string :street_address_2
      t.string :city, null: false
      t.string :state, null: false, limit: 2
      t.string :zip_code, null: false, limit: 5

      t.timestamps
    end

    add_index :people, :last_name
    add_index :people, :created_at
  end
end
