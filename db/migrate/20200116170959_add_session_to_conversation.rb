class AddSessionToConversation < ActiveRecord::Migration[5.2]
  def change
    add_column :conversations, :avatar_session_id, :string
    add_column :conversations, :session_id, :string
  end
end
