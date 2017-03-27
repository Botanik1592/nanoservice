class AddWeekNumberToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :wn, :integer
  end
end
