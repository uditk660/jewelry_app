class AddReceiptNumberToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :receipt_number, :string
    add_index :payments, :receipt_number, unique: true
  end
end
