class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body
      t.string :category
      t.references :user, index: true, foreign_key: true
      t.date :publish_date 

      t.timestamps null: false
    end

    add_column :users, :is_contributor, :boolean, :default => false
  end
end
