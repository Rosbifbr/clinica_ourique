class Client < ApplicationRecord
  has_one_attached :dental_map
  has_many :procedures, dependent: :destroy
  # validates :odontogram_path, allow_blank: true, format: { with: /\A[a-zA-Z0-9_\-\.]+\z/, message: "contains invalid characters" } # Removed

  has_many_attached :images, dependent: :destroy

  # def odontogram_url # Removed
  #   if odontogram_path.present?
  #     "/uploads/odontograms/#{odontogram_path}"
  #   else
  #     "/images/default_odontogram.png"
  #   end
  # end

  # def has_custom_odontogram? # Removed
  #   odontogram_path.present?
  # end
end
