class AddSiteIdToEventMeta < ActiveRecord::Migration
  def up
    add_column :event_meta, :site_id, :integer
  end

  def down
    remove_column :event_meta, :site_id
  end
end
