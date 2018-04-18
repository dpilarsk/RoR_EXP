class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.integer :team_id
      t.string :name
      t.string :slug
      t.integer :retries
      t.boolean :is_validated
      t.integer :final_mark
    end
  end
end
