class CreateEventMeta < ActiveRecord::Migration
  def up
    create_table :event_meta do |t|
      t.string    :key
      t.string    :value
      t.integer   :event_id
    end
  end

  def down
    drop_table :event_meta
  end
end
