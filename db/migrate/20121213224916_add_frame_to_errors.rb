class AddFrameToErrors < ActiveRecord::Migration
  def up
    add_column :errors, :frame, :string
  end

  def down
    remove_column :errors, :frame
  end
end
