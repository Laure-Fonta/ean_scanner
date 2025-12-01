class AddArchivedToInventorySessions < ActiveRecord::Migration[7.1]
  def change
    add_column :inventory_sessions, :archived, :boolean, default: false, null: false
  end
end
