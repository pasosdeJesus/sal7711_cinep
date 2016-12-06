class Loteminsal7711 < ActiveRecord::Migration[5.0]
  # Buscando asegurar que rake sip:indices pondrá valores
  # superiores a 20000 para no ir a interferir con los
  # que OnBase ponga mientras se completa transicion
  def up
    execute <<-SQL
    INSERT INTO lote(id, usuario_id, created_at, updated_at) VALUES 
    (20000, 1, '2016-12-06', '2016-12-06');
    SQL
  end

  def down
    execute <<-SQL
    DELETE FROM lote WHERE id='20000';
    SQL
  end
end
