class AgregaOpcionesUrls < ActiveRecord::Migration
  def change
    add_column :organizacion, :opciones_url_nombre_cif, :string, limit: 1000
    add_column :organizacion, :opciones_url_puerto_cif, :integer
    add_column :organizacion, :opciones_url_nombre_nocif, :string, limit: 1000
    add_column :organizacion, :opciones_url_puerto_nocif, :integer
  end
end
