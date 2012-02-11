class CreateCollectorWorkers < ActiveRecord::Migration
  def change
    create_table :collector_workers do |t|
      t.string :url, :null => false
      t.integer :connection_count , :default=>0

      t.timestamps
    end
  end
end
