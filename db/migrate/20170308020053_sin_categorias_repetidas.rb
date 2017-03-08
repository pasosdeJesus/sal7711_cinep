class SinCategoriasRepetidas < ActiveRecord::Migration[5.0]

  def up
    execute <<-EOF
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Seguridad ciudadana, milicias urbanas, bandas y pandillas, pactos en Bogotá' WHERE id='48';
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Marchas Campesinas' WHERE id='75';
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Marchas Laborales' WHERE id='93';
    EOF
  end

  def down
    execute <<-EOF
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Seguridad ciudadana, milicias urbanas, bandas y pandillas, pactos' WHERE id='48';
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Marchas' WHERE id='75';
      UPDATE sal7711_gen_categoriaprensa SET NOMBRE='Marchas' WHERE id='93';

    EOF
  end
end
