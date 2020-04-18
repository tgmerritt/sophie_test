class ChangeExpirationTimestampOnLingmo < ActiveRecord::Migration[5.2]
  def change
    change_column :lingmos, :expiration_timestamp, :timestamp
  end
end
