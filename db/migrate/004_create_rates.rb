class CreateRates < ActiveRecord::Migration[5.0]
  def change
    create_table :rates do |t|
      t.date :date, null: false
      t.string :metal_type, null: false
      t.integer :price_cents_per_gram, null: false, default: 0

      t.timestamps null: false
    end
    add_index :rates, [:date, :metal_type], unique: true
  end
end
