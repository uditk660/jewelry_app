class CreatePaymentsAndAddCustomerBalance < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.integer :order_id, null: false
      t.integer :customer_id
      t.integer :amount_cents, null: false, default: 0
      t.string :payment_method
      t.text :note
      t.timestamps
    end
    add_index :payments, :order_id
    add_index :payments, :customer_id

    add_column :customers, :balance_cents, :integer, default: 0, null: false
  end
end
