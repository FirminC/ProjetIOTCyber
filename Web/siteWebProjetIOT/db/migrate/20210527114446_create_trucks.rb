class CreateTrucks < ActiveRecord::Migration[5.2]
  def change
    create_table :trucks do |t|
      t.string :hex_identifier
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
