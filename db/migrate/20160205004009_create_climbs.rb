class CreateClimbs < ActiveRecord::Migration
  def change
    create_table :climbs do |t|
      t.references :user, index: true, foreign_key: true
      t.string :climb_type
      t.integer :grade
      t.boolean :success
      t.string :location
      t.string :name
      t.integer :length
      t.string :length_unit
      t.boolean :outdoor, default: true
      t.text :notes

      t.timestamps null: false
    end
  end
end
