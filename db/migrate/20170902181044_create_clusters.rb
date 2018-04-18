class CreateClusters < ActiveRecord::Migration[5.1]
  def change
    create_table :clusters do |t|

      t.timestamps
    end
  end
end
