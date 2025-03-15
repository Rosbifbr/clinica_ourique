class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :cpf, null: false
      t.string :phone
      t.date :birthdate
      t.string :address
      t.string :postal_code
      t.string :neighborhood

      t.timestamps
    end

    # Adding indexes for frequently searched fields
    add_index :clients, :cpf, unique: true
    add_index :clients, :name
  end
end
