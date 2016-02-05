class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.string :label
      t.references :user, index: true, foreign_key: true
      t.string :type
      t.integer :perception

      t.timestamps null: false
    end
  end
end
