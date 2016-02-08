class CreateMicrocycles < ActiveRecord::Migration
  def change
    create_table :microcycles do |t|
      t.string :label
      t.string :microcycle_type
      t.references :user, index: true, foreign_key: true
      t.integer :duration, default: 604800

      t.timestamps null: false
    end
  end
end
