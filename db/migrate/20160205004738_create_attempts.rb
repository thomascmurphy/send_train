class CreateAttempts < ActiveRecord::Migration
  def change
    create_table :attempts do |t|
      t.datetime :date
      t.integer :completion
      t.references :climb, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
