class ChangeUserIdToPersonIdInProjects < ActiveRecord::Migration[5.1]
  def change
    rename_column :projects, :user_id, :person_id
  end
end
