class CreateOrdersAndLineItems < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.string :status, null: false, default: 'pending'
      t.timestamps null: false
    end

    create_table :line_items do |t|
      t.references :order, foreign_key: true, null: false
      t.references :jewelry_item, foreign_key: true, null: false
      t.integer :price_cents, null: false, default: 0
      t.integer :quantity, null: false, default: 1
      t.timestamps null: false
    end
  end
end
