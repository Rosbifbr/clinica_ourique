class CreateOperations < ActiveRecord::Migration[8.0]
  def change
    create_table :operations do |t|
      t.references :client, null: false, foreign_key: true
      t.text :description
      t.date :date
      t.decimal :cost
      t.string :status

      t.timestamps
    end
  end
end
