class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.string :name
      t.text :description
      t.integer :client_id
      t.integer :space_id

      t.timestamps
    end
  end
end
