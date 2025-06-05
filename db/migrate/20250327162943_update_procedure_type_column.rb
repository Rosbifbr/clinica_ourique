 class UpdateProcedureTypeColumn < ActiveRecord::Migration[8.0]
      def up
        unless column_exists?(:procedures, :procedure_type_id)
          add_column :procedures, :procedure_type_id, :integer
        end

        unless index_exists?(:procedures, :procedure_type_id)
          add_index :procedures, :procedure_type_id
        end

        if column_exists?(:procedures, :procedure_type)
          remove_column :procedures, :procedure_type
        end

        unless foreign_key_exists?(:procedures, :procedure_types)
          add_foreign_key :procedures, :procedure_types
        end
      end

      def down
        unless column_exists?(:procedures, :procedure_type)
          add_column :procedures, :procedure_type, :string
        end

        if foreign_key_exists?(:procedures, :procedure_types)
          remove_foreign_key :procedures, :procedure_types
        end

        if index_exists?(:procedures, :procedure_type_id)
          remove_index :procedures, :procedure_type_id
        end

        if column_exists?(:procedures, :procedure_type_id)
          remove_column :procedures, :procedure_type_id
        end
      end
    end
