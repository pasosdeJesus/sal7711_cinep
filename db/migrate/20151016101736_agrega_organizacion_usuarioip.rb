class AgregaOrganizacionUsuarioip < ActiveRecord::Migration
  def change
    add_column :organizacion, :usuarioip_id, :integer
    add_foreign_key :organizacion, :usuario, column: :usuarioip_id
  end
end
