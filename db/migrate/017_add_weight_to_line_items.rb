class AddWeightToLineItems < ActiveRecord::Migration[5.0]
  def change
    add_column :line_items, :weight, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
