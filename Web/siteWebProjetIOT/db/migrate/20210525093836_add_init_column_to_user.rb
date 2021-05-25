class AddInitColumnToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :initialized, :boolean, :default => false, :after =>  :admin_permissions
    #Ex:- :default =>''
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
