class UpdateProceduresTable < ActiveRecord::Migration[8.0]
  def change
    rename_column :procedures, :name, :procedure_type
    rename_column :procedures, :description, :observation
    add_column :procedures, :teeth, :string
    change_column :procedures, :date, :date
  end
end
