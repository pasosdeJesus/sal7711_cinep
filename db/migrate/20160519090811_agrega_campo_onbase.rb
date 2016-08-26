class AgregaCampoOnbase < ActiveRecord::Migration
  def change
    add_column :sal7711_gen_articulo, :onbase_itemnum, :integer
  end
end
