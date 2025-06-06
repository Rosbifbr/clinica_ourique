class RemoveOdontogramPathFromClients < ActiveRecord::Migration[8.0]
  def change
    remove_column :clients, :odontogram_path, :string
  end
end
