class AddAffliationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :occupation, :text
  end
end
