class MejoraVelocidad < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
    CREATE UNIQUE INDEX md_articulo_id ON md_articulo (id);
    CREATE INDEX sal7711_gen_articulo_fecha ON sal7711_gen_articulo (fecha);
    CREATE INDEX sal7711_gen_articulo_departamento ON sal7711_gen_articulo (departamento_id);
    CREATE INDEX sal7711_gen_articulo_municipio ON sal7711_gen_articulo (municipio_id);
    CREATE INDEX sal7711_gen_articulo_fuenteprensa ON sal7711_gen_articulo (fuenteprensa_id);
    CREATE INDEX sal7711_gen_articulo_pagina ON sal7711_gen_articulo (pagina);
    SQL
  end
  def down
    execute <<-SQL
    DROP UNIQUE INDEX md_articulo_id;
    DROP INDEX sal7711_gen_articulo_fecha;
    DROP INDEX sal7711_gen_articulo_departamento;
    DROP INDEX sal7711_gen_articulo_municipio;
    DROP INDEX sal7711_gen_articulo_fuenteprensa;
    DROP INDEX sal7711_gen_articulo_pagina;
    SQL

  end
end
