class CreateSupplierItems < ActiveRecord::Migration[7.1]
  def change
    create_table :supplier_items do |t|
      t.references :supplier, null: false, foreign_key: true
      t.string :ean
      t.string :name

      t.timestamps
    end
  end
end
