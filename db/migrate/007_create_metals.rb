class CreateMetals < ActiveRecord::Migration[5.0]
  def change
    create_table :metals do |t|
      t.string :name, null: false
      t.string :base_unit
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
