class AgregaBc < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION f_unaccent(text)
        RETURNS text AS
      $func$
      SELECT public.unaccent('public.unaccent', $1)  
      $func$  LANGUAGE sql IMMUTABLE;

      CREATE MATERIALIZED VIEW md_articulo AS (SELECT 
      sal7711_gen_articulo.id, fecha || ' ' || 
      COALESCE(texto, '') || ' ' || 
      COALESCE(sip_departamento.nombre, '') || ' ' ||
      COALESCE(sip_municipio.nombre, '') || ' ' || 
      COALESCE(sip_fuenteprensa.nombre, '') || ' ' ||
      COALESCE(pagina, '') AS mdt FROM sal7711_gen_articulo LEFT JOIN
      sip_departamento ON departamento_id = sip_departamento.id LEFT JOIN
      sip_municipio ON municipio_id = sip_municipio.id LEFT JOIN
      sip_fuenteprensa ON fuenteprensa_id = sip_fuenteprensa.id);

      CREATE INDEX md_articulo_b ON md_articulo
      USING gin(to_tsvector('spanish', f_unaccent(mdt)));
    SQL
  end
  def down
    execute <<-SQL
      DROP INDEX md_articulo_b;
      DROP MATERIALIZED VIEW md_articulo;
      DROP FUNCTION f_unaccent(text);
    SQL
  end
end
