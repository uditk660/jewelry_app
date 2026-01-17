class AddHuidAndRateToLineItems < ActiveRecord::Migration[5.0]
  def change
    add_column :line_items, :huid, :string
    add_column :line_items, :rate, :decimal, precision: 12, scale: 2, default: "0.0"
  end
end
