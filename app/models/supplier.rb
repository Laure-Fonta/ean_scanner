class Supplier < ApplicationRecord
  has_many :supplier_items, dependent: :destroy
  has_many :inventory_scans
  has_many :inventory_sessions
end
