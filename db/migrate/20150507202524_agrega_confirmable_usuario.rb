class AgregaConfirmableUsuario < ActiveRecord::Migration

  # https://github.com/plataformatec/devise/wiki/How-To:-Add-:confirmable-to-Users
  def up
    add_column :usuario, :confirmation_token, :string
    add_column :usuario, :confirmed_at, :datetime
    add_column :usuario, :confirmation_sent_at, :datetime
    add_column :usuario, :unconfirmed_email, :string # Only if using reconfirmable
    add_index :usuario, :confirmation_token, unique: true
    execute("UPDATE usuario SET confirmed_at = NOW()")
  end
  def down
    remove_columns :usuario, :confirmation_token, :confirmed_at, 
      :confirmation_sent_at
    remove_columns :usuario, :unconfirmed_email 
  end
end
