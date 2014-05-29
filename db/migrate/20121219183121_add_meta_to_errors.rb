class AddMetaToErrors < ActiveRecord::Migration
  def up
    add_column :errors, :meta, :text
  end

  def down
    remove_column :errors, :meta
  end
end
