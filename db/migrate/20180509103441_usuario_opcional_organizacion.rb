class UsuarioOpcionalOrganizacion < ActiveRecord::Migration[5.2]
  def change
    change_column :organizacion, :usuarioip_id, :integer, null: false
  end
end
