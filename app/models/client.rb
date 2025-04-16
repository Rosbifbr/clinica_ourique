class Client < ApplicationRecord
  has_many :procedures, dependent: :destroy
  validates :odontogram_path, allow_blank: true, format: { with: /\A[a-zA-Z0-9_\-\.]+\z/, message: "contains invalid characters" }

  has_many_attached :images, dependent: :destroy

  def odontogram_url
    if odontogram_path.present?
      "/uploads/odontograms/#{odontogram_path}"
    else
      "/images/default_odontogram.png"
    end
  end

  def has_custom_odontogram?
    odontogram_path.present?
  end
end
