class CreateLingmos < ActiveRecord::Migration[5.2]
  def change
    create_table :lingmos do |t|
      t.string :token
      t.string :owner
      t.integer :lingmo_id
      t.timestamp :expires_at
      t.string :request_endpoint

      t.timestamps
    end
  end
end
