class User < ApplicationRecord
  # Ensure the password is always stored as plain text
  validates :name, presence: true
  validates :password, presence: true
end
