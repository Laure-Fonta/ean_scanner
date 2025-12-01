class InventorySession < ApplicationRecord
  belongs_to :supplier, optional: true

  has_many :inventory_scans, dependent: :destroy

  scope :active,   -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
end
