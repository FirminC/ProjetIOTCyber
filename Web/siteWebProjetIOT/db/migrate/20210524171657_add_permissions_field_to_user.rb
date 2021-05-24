class AddPermissionsFieldToUser < ActiveRecord::Migration[5.2]
  def change
    add_column("users", "admin_permissions", :boolean, :after => "password_digest")
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
