class Client < ApplicationRecord
  has_many :operations, dependent: :destroy
  has_many :billings, dependent: :destroy

  validates :name, presence: true
  validates :cpf, presence: true, uniqueness: { case_sensitive: false }
end
