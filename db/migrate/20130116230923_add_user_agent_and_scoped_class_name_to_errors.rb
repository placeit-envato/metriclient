class AddUserAgentAndScopedClassNameToErrors < ActiveRecord::Migration
  def up
    add_column :errors, :user_agent, :text
    add_column :errors, :scoped_class_name, :string
  end

  def down
    remove_column :errors, :user_agent
    remove_column :errors, :scoped_class_name
  end
end
