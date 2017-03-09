class SinCategoriasRepetidas < ActiveRecord::Migration[5.0]

  def up
    execute <<-EOF
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Seguridad ciudadana, milicias urbanas, bandas y pandillas, pactos en Bogotá' WHERE codigo='B65';
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Marchas' WHERE codigo='D55';
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Marchas Campesinas' WHERE codigo='D75';
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Marchas Laborales' WHERE codigo='D93';
    EOF
  end

  def down
    execute <<-EOF
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Seguridad ciudadana, milicias urbanas, bandas y pandillas, pactos' WHERE codigo='B65';
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Marchas' WHERE codigo='D55';
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Marchas' WHERE codigo='D75';
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Marchas' WHERE codigo='D93';
    EOF
  end
end
