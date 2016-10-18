class Renombrageolote < ActiveRecord::Migration[5.0]
  def change
    rename_column :lote, :canddepartamento, :canddepartamento_id
    rename_column :lote, :candmunicipio, :candmunicipio_id
  end
end
