class CreateEventsArchive < ActiveRecord::Migration
  def up
    create_table :events_archive, options: "ENGINE=MyISAM" do |t|
      t.string    :event_type
      t.integer   :site_id
      t.timestamps
    end

    add_index :events_archive, [:event_type, :created_at], :name => "event_type"
  end

  def down
    drop_table :events_archive
  end
end
