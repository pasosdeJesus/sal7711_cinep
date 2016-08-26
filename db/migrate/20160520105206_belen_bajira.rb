class BelenBajira < ActiveRecord::Migration
  def up
    execute <<-SQL
    INSERT INTO sip_municipio (id, nombre, id_departamento, id_munlocal, latitud, longitud, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (9000, 'BELÉN DE BAJIRÁ', 27, 999, 0, 0, '2000-06-19', '2007-11-15', '2016-05-20', '2016-05-20', 'https://es.wikipedia.org/wiki/Bel%C3%A9n_de_Bajir%C3%A1');
    SQL
  end
  def down
  end
end
