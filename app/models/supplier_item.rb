class SupplierItem < ApplicationRecord
  include EanNormalizer

  belongs_to :supplier

  validates :ean, presence: true
end
