class AddCategoriaprensaLote < ActiveRecord::Migration[5.0]
  def change
    add_column :lote, :candcategoriaprensa_id, :integer
  end
end
