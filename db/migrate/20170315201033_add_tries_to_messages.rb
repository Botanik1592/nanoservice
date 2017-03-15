class AddTriesToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :tries, :integer
  end
end
