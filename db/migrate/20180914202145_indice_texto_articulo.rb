class IndiceTextoArticulo < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE INDEX sal7711_gen_articulo_texto ON sal7711_gen_articulo 
        USING gin(to_tsvector('spanish', f_unaccent(COALESCE(texto, ''))));
    SQL
  end
  def down
    execute <<-SQL
      DROP INDEX sal7711_gen_articulo_texto;
    SQL
  end
end
