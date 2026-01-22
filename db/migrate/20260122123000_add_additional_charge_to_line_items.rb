class AddAdditionalChargeToLineItems < ActiveRecord::Migration[5.0]
  def change
    add_column :line_items, :additional_charge, :decimal, precision: 12, scale: 2, default: 0.0
  end
end
