class AddSlugToPostsAndCategories < ActiveRecord::Migration
  def change
    add_column Refinery::Blog::Post.table_name, :slug, :string
    # change_column is needed to add ":null => false"
    # to get around a SQLite glitch, see http://stackoverflow.com/a/6710280/869616
    change_column Refinery::Blog::Post.table_name, :slug, :string, :null => false
    add_index Refinery::Blog::Post.table_name, :slug, unique: true

    add_column Refinery::Blog::Category.table_name, :slug, :string
    change_column Refinery::Blog::Category.table_name, :slug, :string, :null => false
    add_index Refinery::Blog::Category.table_name, :slug, unique: true
  end
end