class RenameOldTableToNewTable < ActiveRecord::Migration[5.1]
  def change
	  rename_table :users, :persons
	  rename_table :persons, :people
  end
end
