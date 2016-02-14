class CreateMesocycles < ActiveRecord::Migration
  def change
    create_table :mesocycles do |t|
      t.string :label
      t.string :mesocycle_type
      t.references :user, index: true, foreign_key: true
      t.integer :reference_id

      t.timestamps null: false
    end
  end
end
