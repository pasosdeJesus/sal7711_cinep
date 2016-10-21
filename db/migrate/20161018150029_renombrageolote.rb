class Renombrageolote < ActiveRecord::Migration[5.0]
  def up
    rename_column :lote, :canddepartamento, :canddepartamento_id
    rename_column :lote, :candmunicipio, :candmunicipio_id
    rename_column :lote, :candfuenteprensa, :candfuenteprensa_id
    change_column :lote, :candfecha, :date, :null => true
  end
  def down
    rename_column :lote, :canddepartamento_id, :canddepartamento
    rename_column :lote, :candmunicipio_id, :candmunicipio
    rename_column :lote, :candfuenteprensa_id, :candfuenteprensa
    change_column :lote, :candfecha, :date, :null => false
  end
end
