class AgregaVigencia < ActiveRecord::Migration
  def change
    add_column :organizacion, :diasvigencia, :integer
    add_column :organizacion, :fecharenovacion, :date
    add_column :usuario, :diasvigencia, :integer
    add_column :usuario, :fecharenovacion, :date
  end
end
