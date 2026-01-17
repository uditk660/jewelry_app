class CreatePurities < ActiveRecord::Migration[5.0]
  def change
    create_table :purities do |t|
      t.references :metal, foreign_key: true, null: false
      t.string :name
      t.decimal :purity_percent, precision: 8, scale: 4
      t.boolean :active, default: true
      t.decimal :updated_price, precision: 12, scale: 2
      t.text :remarks

      t.timestamps null: false
    end
  end
end
