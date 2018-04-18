class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.integer :uid
      t.string :login
      t.string :first_name
      t.string :last_name
      t.integer :gender
      t.integer :pool_year
      t.string :pool_month
      t.float :level
      t.boolean :is_admitted
    end
  end
end
