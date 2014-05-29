class AddResponsibleToErrors < ActiveRecord::Migration
  def up
    add_column :errors, :responsible, :string
  end

  def down
    remove_column :errors, :responsible
  end
end
