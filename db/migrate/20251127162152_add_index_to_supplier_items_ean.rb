class AddIndexToSupplierItemsEan < ActiveRecord::Migration[7.1]
  def change
    add_index :supplier_items, :ean
  end
end
