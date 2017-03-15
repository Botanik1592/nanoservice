class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.boolean :status, default: false
      t.string :sender, null: false
      t.string :body, null: false
      t.string :reciever, null: false
      t.string :service, null: false

      t.timestamps
    end
  end
end
