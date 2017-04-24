class AmpliaDetalleBitacora < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      ALTER TABLE sal7711_gen_bitacora ALTER COLUMN detalle TYPE TEXT;
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE sal7711_gen_bitacora ALTER COLUMN detalle TYPE VARCHAR(5000);
    SQL
  end
end
