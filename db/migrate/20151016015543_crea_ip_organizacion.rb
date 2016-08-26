class CreaIpOrganizacion < ActiveRecord::Migration
  def change
    create_table :ip_organizacion do |t|
      t.integer :organizacion_id, null: false
      t.inet   :ip, null: false
      # http://edgeguides.rubyonrails.org/active_record_postgresql.html
    end
    add_foreign_key :ip_organizacion, :organizacion
  end
end
