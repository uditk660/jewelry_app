class AddInvoiceToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :invoice_number, :string
    add_column :orders, :sale_date, :date
    add_index :orders, :invoice_number, unique: true
  end
end
