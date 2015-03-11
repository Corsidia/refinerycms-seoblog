class CreateBlogStructure < ActiveRecord::Migration

  def up
    create_table :refinery_blog_posts do |t|
      t.integer :blog_category_id
      t.integer :user_id
      t.string :title
      t.text :body
      t.boolean :draft
      t.datetime :published_at
      t.timestamps null: false
    end

    add_index :refinery_blog_posts, :id
    add_index :refinery_blog_posts, :blog_category_id
    add_index :refinery_blog_posts, :user_id

    create_table :refinery_blog_categories do |t|
      t.string :title
      t.timestamps null: false
    end

    add_index :refinery_blog_categories, :id
  end

  def down
    Refinery::UserPlugin.destroy_all({:name => "refinerycms_seoblog"}) if defined?(Refinery::UserPlugin)

    Refinery::Page.delete_all({:link_url => "/blog"}) if defined?(Refinery::Page)

    drop_table :refinery_blog_posts
    drop_table :refinery_blog_categories
  end

end
