class AgregaFuentes < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      INSERT INTO sip_fuenteprensa 
        (id, nombre, fechacreacion, created_at, updated_at) VALUES
        ('55', 'LA REPLICA', '2016-11-08', '2016-11-08', '2016-11-08');
      INSERT INTO sip_fuenteprensa 
        (id, nombre, fechacreacion, created_at, updated_at) VALUES
        ('56', 'EL SIGLO', '2016-11-08', '2016-11-08', '2016-11-08');
      INSERT INTO sip_fuenteprensa 
        (id, nombre, fechacreacion, created_at, updated_at) VALUES
        ('57', 'EL PERIODICO', '2016-11-08', '2016-11-08', '2016-11-08');
      INSERT INTO sip_fuenteprensa 
        (id, nombre, fechacreacion, created_at, updated_at) VALUES
        ('58', 'EL CORREDOR', '2016-11-08', '2016-11-08', '2016-11-08');
    SQL
  end
  def down
    execute <<-SQL
      DELETE FROM sip_fuenteprensa WHERE id>='55' and id<='58';
    SQL
  end
end
