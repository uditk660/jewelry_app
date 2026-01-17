class AddCustomerToOrders < ActiveRecord::Migration[5.0]
  def change
    add_reference :orders, :customer, index: true, foreign_key: true
  end
end
