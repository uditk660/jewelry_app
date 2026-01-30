class AddTotalWeightToPurities < ActiveRecord::Migration[5.0]
  def change
    add_column :purities, :total_weight, :decimal, precision: 12, scale: 3, default: 0.0, null: false
  end
end
