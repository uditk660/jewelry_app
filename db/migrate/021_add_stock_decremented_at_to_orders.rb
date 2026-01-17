class AddStockDecrementedAtToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :stock_decremented_at, :datetime
    add_index :orders, :stock_decremented_at
  end
end
