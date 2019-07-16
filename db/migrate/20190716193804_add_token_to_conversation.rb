class AddTokenToConversation < ActiveRecord::Migration[5.2]
  def change
    add_column :conversations, :token, :string
  end
end
