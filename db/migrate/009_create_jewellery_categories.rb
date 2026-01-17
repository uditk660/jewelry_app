class CreateJewelleryCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :jewellery_categories do |t|
      t.references :metal, foreign_key: true, null: false
      t.string :name
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
