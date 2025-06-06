class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  # validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  # has_secure_password already adds presence validation for password on create.
  # It also adds confirmation validation if password_confirmation is present.
  # For length, we can add it separately.
  validates :password, length: { minimum: 6 }, allow_nil: true # allow_nil for updates where password isn't changed
end
