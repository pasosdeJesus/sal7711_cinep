class AgregaCamposTexto < ActiveRecord::Migration[5.0]
  def change
    add_column :sal7711_gen_articulo, :textoocr, :text
  end
end
