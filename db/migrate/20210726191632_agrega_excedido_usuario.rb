class AgregaExcedidoUsuario < ActiveRecord::Migration[6.1]
  def change
    add_column :usuario, :excedido, :integer
  end
end
