class ChangeImageUrlFormat < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :image_url, :text
  end
end
