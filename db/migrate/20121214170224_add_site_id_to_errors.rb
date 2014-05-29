class AddSiteIdToErrors < ActiveRecord::Migration
  def up
    add_column :errors, :site_id, :integer
  end

  def down
    remove_column :errors, :site_id
  end
end
