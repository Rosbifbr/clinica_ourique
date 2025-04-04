class UpdateProcedureTypeColumn < ActiveRecord::Migration[8.0]
  def up
    add_column :procedures, :procedure_type_id, :integer
    add_index :procedures, :procedure_type_id
    remove_column :procedures, :procedure_type
    add_foreign_key :procedures, :procedure_types
  end
  def down
    add_column :procedures, :procedure_type, :string
    remove_foreign_key :procedures, :procedure_types
    remove_index :procedures, :procedure_type_id
    remove_column :procedures, :procedure_type_id
  end
end
