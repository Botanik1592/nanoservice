class AddIndexForMultipleColumns < ActiveRecord::Migration[5.0]
  def change
    add_index :messages, [:service, :reciever, :sender, :body]
  end
end
