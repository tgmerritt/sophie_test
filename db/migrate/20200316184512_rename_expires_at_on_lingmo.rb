class RenameExpiresAtOnLingmo < ActiveRecord::Migration[5.2]
  def change
    rename_column :lingmos, :expires_at, :expiration_timestamp
  end
end
