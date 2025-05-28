class CreateBillings < ActiveRecord::Migration[8.0]
  def change
    create_table :billings do |t|
      t.references :client, null: false, foreign_key: true
      t.references :operation, null: false, foreign_key: true
      t.decimal :amount
      t.date :due_date
      t.string :status

      t.timestamps
    end
  end
end
