class AddOdontogramPathToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :odontogram_path, :string
  end
end
