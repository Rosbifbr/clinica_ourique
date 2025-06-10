class AddFieldsToProcedures < ActiveRecord::Migration[8.0]
  def change
    add_column :procedures, :dentist, :string
    add_column :procedures, :debit, :decimal, precision: 8, scale: 2
    add_column :procedures, :credit, :decimal, precision: 8, scale: 2
  end
end
