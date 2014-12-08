module Refinery
  module Blog
    class CategoriesController < BlogController

      def show
        @category = Refinery::Blog::Category.friendly.find(params[:slug])
        @posts = @category.posts.live.includes(:category).with_globalize.page(params[:page])
      end

    end
  end
end
