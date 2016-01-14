class AddIntervalToSpreeLineItems < ActiveRecord::Migration
  def change
    add_column :spree_line_items, :interval, :integer
  end
end
