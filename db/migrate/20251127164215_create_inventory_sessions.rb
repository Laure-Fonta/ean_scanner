class CreateInventorySessions < ActiveRecord::Migration[7.1]
  def change
    create_table :inventory_sessions do |t|
      t.string :name

      t.timestamps
    end
  end
end
