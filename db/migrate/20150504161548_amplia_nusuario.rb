class AmpliaNusuario < ActiveRecord::Migration
  def change
    change_column :usuario, :nusuario, :string, :limit => 255
  end
end
