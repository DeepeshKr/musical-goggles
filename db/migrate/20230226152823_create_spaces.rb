class CreateSpaces < ActiveRecord::Migration[6.1]
  def change
    create_table :spaces do |t|
      t.string :name

      t.timestamps
    end
  end
end
