class InventoryScan < ApplicationRecord
  belongs_to :inventory_session
  belongs_to :supplier, optional: true
  belongs_to :supplier_item, optional: true
end
