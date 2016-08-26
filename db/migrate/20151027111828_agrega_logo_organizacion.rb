class AgregaLogoOrganizacion < ActiveRecord::Migration
  def change
    add_column :organizacion, :url_logoinst, :string, limit: 1000
  end
end
