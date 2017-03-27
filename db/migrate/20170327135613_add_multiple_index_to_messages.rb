class AddMultipleIndexToMessages < ActiveRecord::Migration[5.0]
  def change
    add_index :messages, [:service, :reciever, :sender, :body, :wn], unique: true, :name => 'index_by_params'
  end
end
