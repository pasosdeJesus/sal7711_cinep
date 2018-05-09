class RenombarIpOrganizacion < ActiveRecord::Migration[5.2]
  def change
    rename_table :ip_organizacion, :iporganizacion
  end
end
