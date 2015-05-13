class AddStickyToPosts < ActiveRecord::Migration
  def change
    add_column :refinery_blog_posts, :sticky, :boolean, :default => false
  end
end
