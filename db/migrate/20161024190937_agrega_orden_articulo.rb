class AgregaOrdenArticulo < ActiveRecord::Migration[5.0]
  def change
    add_column :sal7711_gen_articulo, :orden, :string, limit: 100
  end
end
