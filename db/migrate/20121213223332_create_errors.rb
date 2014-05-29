class CreateErrors < ActiveRecord::Migration
  def up
    create_table :errors do |t|
      t.string    :error
      t.string    :line
      t.string    :url
      t.timestamps
    end
  end

  def down
    drop_table :errors
  end
end
