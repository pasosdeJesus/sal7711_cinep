class AgregaAutenticadoPorIpUsuario < ActiveRecord::Migration
  def change
    add_column :usuario, :autenticado_por_ip, :bool
  end
end
