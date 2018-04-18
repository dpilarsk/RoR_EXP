class AddColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :wallets, :integer
    add_column :users, :staff, :boolean
    add_column :users, :location, :string
    add_column :users, :level, :float
  end
end
