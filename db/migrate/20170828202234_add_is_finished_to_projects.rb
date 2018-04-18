class AddIsFinishedToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :is_finished, :string
  end
end
