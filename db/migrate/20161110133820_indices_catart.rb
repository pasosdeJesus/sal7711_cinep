class IndicesCatart < ActiveRecord::Migration[5.0]
  def change
    add_index :sal7711_gen_articulo_categoriaprensa, :articulo_id, name: 's7_artcat_a'
    add_index :sal7711_gen_articulo_categoriaprensa, :categoriaprensa_id, name: 's7_artcat_c'
    add_index :sal7711_gen_articulo_categoriaprensa, [:articulo_id, :categoriaprensa_id], unique: true, name: 's7_artcat_ac'
  end
end
