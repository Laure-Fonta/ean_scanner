class MakeSupplierOptionalInInventoryScans < ActiveRecord::Migration[7.1]
  def change
    change_column_null :inventory_scans, :supplier_id, true
    change_column_null :inventory_scans, :supplier_item_id, true
  end
end
