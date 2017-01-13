class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :parent_message_id, index: true, foreign_key: true
      t.text :body
      t.string :title
      t.references :messageable, polymorphic: true, index: true
      t.boolean :read, default: false
      t.integer :views, default: 0

      t.timestamps null: false
    end
  end
end
