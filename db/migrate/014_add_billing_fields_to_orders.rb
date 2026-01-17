class AddBillingFieldsToOrders < ActiveRecord::Migration[5.0]
  def change
    change_table :orders do |t|
      t.decimal :discount, precision: 10, scale: 2, default: 0.0
      t.decimal :charges, precision: 10, scale: 2, default: 0.0
      t.decimal :gross_weight, precision: 10, scale: 2, default: 0.0
      t.decimal :net_weight, precision: 10, scale: 2, default: 0.0
    end
  end
end
