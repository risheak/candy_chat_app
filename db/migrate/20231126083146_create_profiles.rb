class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.string :name
      t.integer :category
      t.integer :gender

      t.timestamps
    end
  end
end
