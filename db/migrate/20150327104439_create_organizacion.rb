class CreateOrganizacion < ActiveRecord::Migration
  def change
    create_table :organizacion do |t|
      t.string :nombre, limit: 1000
      t.string :observaciones, limit: 5000
      t.date :fechacreacion
      t.date :fechadeshabilitacion
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
