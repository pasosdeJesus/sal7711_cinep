class CreateLote < ActiveRecord::Migration[5.0]
  def change
    create_table :lote do |t|
      t.integer :usuario_id, null: false
      t.date :candfecha, null: false
      t.integer :canddepartamento
      t.integer :candmunicipio
      t.integer :candfuenteprensa
      t.timestamps
    end
    add_foreign_key :lote, :usuario, column: :usuario_id
    add_foreign_key :lote, :sip_departamento, column: :canddepartamento
    add_foreign_key :lote, :sip_municipio, column: :candmunicipio
    add_foreign_key :lote, :sip_fuenteprensa, column: :candfuenteprensa
  end
end
