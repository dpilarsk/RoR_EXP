class ChangeIsAdmittedToInteger < ActiveRecord::Migration[5.1]
  def change
    change_column :people, :is_admitted, :integer
  end
end
