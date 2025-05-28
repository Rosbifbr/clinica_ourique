class Billing < ApplicationRecord
  belongs_to :client
  belongs_to :operation, optional: true

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :due_date, presence: true
  validates :status, presence: true
end
