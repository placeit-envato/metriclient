class CreateErrorsArchive < ActiveRecord::Migration
  def up
    create_table :errors_archive, options: "ENGINE=MyISAM" do |t|
      t.string    :error
      t.string    :line
      t.string    :url
      t.timestamps
      t.string    :frame
      t.string    :responsible
      t.integer   :site_id
      t.text      :meta
      t.text      :user_agent
      t.string    :scoped_class_name
    end

    add_index :errors_archive, [:error, :created_at, :site_id], :name => 'error'
  end

  def down
    drop_table :errors_archive
  end
end
