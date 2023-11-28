class AddIndexToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_index :profiles, [:gender, :category]
    add_index :profiles, [:category]
  end
end
