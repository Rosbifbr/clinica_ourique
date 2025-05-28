class AddDentalMapImageBase64ToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :dental_map_image_base64, :text
  end
end
