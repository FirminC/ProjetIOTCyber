class AddOtpSecretToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :otp_secret, :string
    add_column :users, :last_otp_at, :integer
  end
end
