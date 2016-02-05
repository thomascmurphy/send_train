class CreateClimbs < ActiveRecord::Migration
  def change
    create_table :climbs do |t|
      t.references :user, index: true, foreign_key: true
      t.string :grade
      t.boolean :success
      t.string :location
      t.string :name
      t.integer :length
      t.string :length_unit

      t.timestamps null: false
    end
  end
end
