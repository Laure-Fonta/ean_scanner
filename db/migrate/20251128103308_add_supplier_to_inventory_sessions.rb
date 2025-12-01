class AddSupplierToInventorySessions < ActiveRecord::Migration[7.1]
  def change
    add_reference :inventory_sessions, :supplier, foreign_key: true, null: true
  end
end
