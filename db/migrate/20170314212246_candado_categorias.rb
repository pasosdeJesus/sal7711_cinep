class CandadoCategorias < ActiveRecord::Migration[5.0]
  def change
    rename_column :lote, :candcategoriaprensa_id, :candcategoria1_id
    add_column :lote, :candcategoria2_id, :integer
    add_column :lote, :candcategoria3_id, :integer
  end
end
