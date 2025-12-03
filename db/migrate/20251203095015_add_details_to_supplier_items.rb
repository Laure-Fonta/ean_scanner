class AddDetailsToSupplierItems < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_items, :ref, :string
    add_column :supplier_items, :nom, :string
    add_column :supplier_items, :coloris, :string
    add_column :supplier_items, :taille, :string
  end
end
