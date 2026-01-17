class CreateCustomers < ActiveRecord::Migration[5.0]
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.text :address
      t.string :aadhaar_or_pan
      t.string :gst_number
      t.string :email
      t.string :phone

      t.timestamps null: false
    end

    add_index :customers, :phone, unique: true
    add_index :customers, :email, unique: true
  end
end
