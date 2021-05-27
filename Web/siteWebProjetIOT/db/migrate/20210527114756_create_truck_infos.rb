class CreateTruckInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :truck_infos do |t|
      t.references :truck, foreign_key: true
      t.boolean :is_stolen
      t.integer :fuel_level
      t.float :lat
      t.float :lon

      t.timestamps
    end
  end
end
