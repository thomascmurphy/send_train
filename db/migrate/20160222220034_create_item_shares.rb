class CreateItemShares < ActiveRecord::Migration
  def change
    create_table :item_shares do |t|
      t.integer :sharer_id
      t.integer :recipient_id
      t.references :item, polymorphic: true, index: true
      t.boolean :sent, default: false
      t.boolean :received, default: false
      t.boolean :accepted
      t.text :notes

      t.timestamps null: false
    end

    add_column :users, :accept_shares, :boolean, default: true
  end
end
