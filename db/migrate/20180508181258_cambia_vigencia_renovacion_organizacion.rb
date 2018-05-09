class CambiaVigenciaRenovacionOrganizacion < ActiveRecord::Migration[5.2]
  def change
    change_column :organizacion, :usuarioip_id, :integer, null: false
    remove_column :organizacion, :fecharenovacion, :date
    remove_column :organizacion, :diasvigencia, :integer
  end
end
