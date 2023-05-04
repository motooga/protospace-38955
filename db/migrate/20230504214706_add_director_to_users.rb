class AddDirectorToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :position, :text
  end
end
