class Operation < ApplicationRecord
  belongs_to :client
  has_many :billings, dependent: :destroy

  validates :description, presence: true
  validates :date, presence: true
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true
end
