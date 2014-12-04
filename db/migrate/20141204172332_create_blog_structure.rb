class CreateBlogStructure < ActiveRecord::Migration

  def up
    create_table :refinery_blog_posts do |t|
      t.string :title
      t.text :body
      t.boolean :draft
      t.datetime :published_at
      t.timestamps
    end

    add_index :refinery_blog_posts, :id

    create_table :refinery_blog_comments do |t|
      t.integer :blog_post_id
      t.boolean :spam
      t.string :name
      t.string :email
      t.text :body
      t.string :state
      t.timestamps
    end

    add_index :refinery_blog_comments, :id
    add_index :refinery_blog_comments, :blog_post_id

    create_table :refinery_blog_categories do |t|
      t.integer :blog_post_id
      t.string :title
      t.timestamps
    end

    add_index :refinery_blog_categories, :id
    add_index :refinery_blog_categories, :blog_post_id
  end

  def down
    Refinery::UserPlugin.destroy_all({:name => "refinerycms_blog"}) if defined?(Refinery::UserPlugin)

    Refinery::Page.delete_all({:link_url => "/blog"}) if defined?(Refinery::Page)

    drop_table :refinery_blog_posts
    drop_table :refinery_blog_comments
    drop_table :refinery_blog_categories
  end

end
