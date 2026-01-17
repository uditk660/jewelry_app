class ChangeWeightGramsToDecimal < ActiveRecord::Migration[5.0]
  def up
    add_column :jewelry_items, :weight_grams_tmp, :decimal, precision: 10, scale: 2, default: 0.0, null: false
    # copy existing integer values into the decimal column
    execute <<-SQL.squish
      UPDATE jewelry_items SET weight_grams_tmp = weight_grams;
    SQL
    remove_column :jewelry_items, :weight_grams
    rename_column :jewelry_items, :weight_grams_tmp, :weight_grams
  end

  def down
    add_column :jewelry_items, :weight_grams_int, :integer, default: 0, null: false
    execute <<-SQL.squish
      UPDATE jewelry_items SET weight_grams_int = CAST(weight_grams AS INTEGER);
    SQL
    remove_column :jewelry_items, :weight_grams
    rename_column :jewelry_items, :weight_grams_int, :weight_grams
  end
end
