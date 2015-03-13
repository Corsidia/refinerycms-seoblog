module Refinery
  module Blog
    class Category < ActiveRecord::Base
      extend FriendlyId

      translates :title, :slug

      friendly_id :title, :use => [:slugged, :globalize]

      has_many :posts, class_name: "Refinery::Blog::Post", foreign_key: :blog_category_id

      validates :title, :presence => true, :uniqueness => true
      validates :slug, :presence => true

      # we want to regenerate the slug on title update
      def should_generate_new_friendly_id?
        true
      end

      def self.by_title(title)
        joins(:translations).find_by(title: title)
      end

      def self.translated
        with_translations(::Globalize.locale)
      end

      def post_count
        posts.live.with_globalize.count
      end

      # how many items to show per page
      self.per_page = Refinery::Blog.posts_per_page

    end
  end
end
