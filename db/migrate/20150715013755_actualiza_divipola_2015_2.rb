class ActualizaDivipola20152 < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE sip_departamento SET nombre = 'BOGOTÁ, D.C.' WHERE id = '4';
      UPDATE sip_departamento SET nombre = 'QUINDÍO' WHERE id = '41';
      REFRESH MATERIALIZED VIEW sip_mundep;
    SQL
  end
  def down
  end
end
