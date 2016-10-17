class AgregaIdArticuloCategoriaprensa < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE SEQUENCE sal7711_gen_articulo_categoriaprensa_id_seq;
    SQL
    execute <<-SQL
      ALTER TABLE sal7711_gen_articulo_categoriaprensa 
        ADD COLUMN id INTEGER NOT NULL 
          DEFAULT(nextval('sal7711_gen_articulo_categoriaprensa_id_seq'));
    SQL
    execute <<-SQL
      ALTER TABLE sal7711_gen_articulo_categoriaprensa 
        ADD CONSTRAINT sal7711_gen_articulo_categoriaprensa_pkey 
          PRIMARY KEY (id);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE sal7711_gen_articulo_categoriaprensa 
        DROP CONSTRAINT IF EXISTS sal7711_gen_articulo_categoriaprensa_pkey   
          CASCADE;
    SQL
    execute <<-SQL
      ALTER TABLE sal7711_gen_articulo_categoriaprensa DROP COLUMN id;
    SQL
    execute <<-SQL
      DROP SEQUENCE sal7711_gen_articulo_categoriaprensa_id_seq;
    SQL

  end
end
