class CreateSpeaks < ActiveRecord::Migration[5.2]
  def change
    create_table :speaks do |t|

      t.timestamps
    end
  end
end
