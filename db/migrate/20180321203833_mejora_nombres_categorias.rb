class MejoraNombresCategorias < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      UPDATE sal7711_gen_categoriaprensa SET 
        nombre = 'Marchas de pobladores urbanos' WHERE codigo='D55';
      UPDATE sal7711_gen_categoriaprensa SET 
        nombre = 'Marchas gremios, empresarios y trabajadores independientes' WHERE codigo='D93';
      UPDATE sal7711_gen_categoriaprensa SET 
        nombre = 'Marchas campesinas' WHERE codigo='D75';
    SQL
  end
  def down
    execute <<-SQL
      UPDATE sal7711_gen_categoriaprensa SET 
        nombre = 'Marchas' WHERE codigo='D55';
      UPDATE sal7711_gen_categoriaprensa SET 
        nombre = 'Marchas laborales';
      UPDATE sal7711_gen_categoriaprensa SET 
        nombre = 'Marchas campesinas' WHERE codigo='D75';
    SQL
  end
end
