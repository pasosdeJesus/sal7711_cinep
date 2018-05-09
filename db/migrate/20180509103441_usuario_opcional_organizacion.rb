class UsuarioOpcionalOrganizacion < ActiveRecord::Migration[5.2]
  def up
    change_column :organizacion, :usuarioip_id, :integer, null: true
    change_column :organizacion, :fechacreacion, :date, null: false
    change_column :organizacion, :created_at, :date, null: false
    change_column :organizacion, :updated_at, :date, null: false
  end
  def down
  end
end
