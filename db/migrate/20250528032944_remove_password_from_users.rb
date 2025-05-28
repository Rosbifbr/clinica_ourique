class RemovePasswordFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :password, :string
  end
end
