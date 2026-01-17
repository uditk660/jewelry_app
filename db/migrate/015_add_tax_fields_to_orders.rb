class AddTaxFieldsToOrders < ActiveRecord::Migration[5.0]
  def change
    change_table :orders do |t|
      t.decimal :cgst_rate, precision: 6, scale: 2, default: 0.0
      t.decimal :igst_rate, precision: 6, scale: 2, default: 0.0
      t.integer :cgst_cents, default: 0
      t.integer :igst_cents, default: 0
    end
  end
end
