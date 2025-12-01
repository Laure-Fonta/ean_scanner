class SupplierItem < ApplicationRecord
  belongs_to :supplier

  validates :ean, presence: true
end
