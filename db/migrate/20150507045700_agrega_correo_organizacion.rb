class AgregaCorreoOrganizacion < ActiveRecord::Migration
  def change
    add_column :organizacion, :autoregistro, :bool, default: false
    add_column :organizacion, :dominiocorreo, :string, limit: 500
    add_column :organizacion, :pexcluyecorreo, :string, limit: 500
  end
end
