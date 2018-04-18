class AddCursusIdToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :cursus_id, :integer
  end
end
