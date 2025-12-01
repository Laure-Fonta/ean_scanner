class CreateInventoryScans < ActiveRecord::Migration[7.1]
  def change
    create_table :inventory_scans do |t|
      t.references :inventory_session, null: false, foreign_key: true
      t.string :ean
      t.boolean :found
      t.references :supplier, null: false, foreign_key: true
      t.references :supplier_item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
