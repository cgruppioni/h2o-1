class AllowCasesFullNameToBeNull < ActiveRecord::Migration
  def self.up
    change_column :cases, :name, :string, :limit => 500, :null => true 
  end

  def self.down
    change_column :cases, :name, :string, :limit => 500, :null => false 
  end
end
