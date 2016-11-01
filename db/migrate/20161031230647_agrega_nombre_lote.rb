class AgregaNombreLote < ActiveRecord::Migration[5.0]
  def change
    add_column :lote, :nombre, :string, limit: 511
  end
end
