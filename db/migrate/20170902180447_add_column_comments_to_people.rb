class AddColumnCommentsToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :comments, :text
  end
end
