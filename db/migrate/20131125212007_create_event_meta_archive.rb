class CreateEventMetaArchive < ActiveRecord::Migration
  def up
    create_table :event_meta_archive, options: "ENGINE=MyISAM" do |t|
      t.string    :key
      t.text      :value
      t.integer   :event_id
      t.integer   :site_id
    end

    add_index :event_meta_archive, [:key, :site_id, :value], {:name => 'key', :length => {:value => 11}}
    add_index :event_meta_archive, :event_id, :name => 'Event ID'
  end

  def down
    drop_table :event_meta_archive
  end
end
