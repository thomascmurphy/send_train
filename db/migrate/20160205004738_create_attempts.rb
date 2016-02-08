class CreateAttempts < ActiveRecord::Migration
  def change
    create_table :attempts do |t|
      t.datetime :date, default: DateTime.now
      t.integer :completion, default: 0
      t.references :climb, index: true, foreign_key: true
      t.boolean :onsight, default: false
      t.boolean :flash, default: false

      t.timestamps null: false
    end
  end
end
