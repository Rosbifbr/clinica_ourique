class AddObservationToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :observation, :text
  end
end
