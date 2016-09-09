class ArticuloEnLote < ActiveRecord::Migration[5.0]
  def change
    add_column :sal7711_gen_articulo, :lote_id, :integer
    change_column_null :sal7711_gen_articulo, :fuenteprensa_id, true
    change_column_null :sal7711_gen_articulo, :fecha, true
    change_column_null :sal7711_gen_articulo, :pagina, true
    add_foreign_key :sal7711_gen_articulo, :lote, column: :lote_id
  end
  # Se podría agregar un lote inicial, posiblemente 0 en el cual poner
  # lo artículos existentes o los que se agreguen fuera de lotes, pero
  # parece no coincidir con el propósito de un lote, agrupar los
  # artículos que se sistematicen en grupo.
end
