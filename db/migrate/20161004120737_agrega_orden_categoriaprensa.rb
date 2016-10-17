class AgregaOrdenCategoriaprensa < ActiveRecord::Migration[5.0]
  def change
    add_column :sal7711_gen_articulo_categoriaprensa, :orden, :integer
  end
end
