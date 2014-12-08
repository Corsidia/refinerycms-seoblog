module Refinery
  module Blog
    class PostsController < BlogController

      before_action :find_all_blog_posts, :except => [:archive]
      before_action :find_blog_post, :only => [:show, :update_nav]
      before_action :find_tags

      respond_to :html, :js, :rss

      def index
        if request.format.rss?
          @posts = if params["max_results"].present?
            # limit rss feed for services (like feedburner) who have max size
            Post.recent(params["max_results"])
          else
            Post.newest_first.live.includes(:category)
          end
        end
        respond_with (@posts) do |format|
          format.html
          format.rss { render :layout => false }
        end
      end

      def show
        @canonical = refinery.url_for(:locale => Refinery::I18n.current_frontend_locale) if canonical?
        @post.increment!(:access_count, 1)

        respond_with (@post) do |format|
          format.html { present(@post) }
          format.js { render :partial => 'post', :layout => false }
        end
      end

      def archive
        if params[:month].present?
          date = "#{params[:month]}/#{params[:year]}"
          archive_date = Time.parse(date)
          @date_title = ::I18n.l(archive_date, :format => '%B %Y')
          @posts = Post.live.by_month(archive_date).page(params[:page])
        else
          date = "01/#{params[:year]}"
          archive_date = Time.parse(date)
          @date_title = ::I18n.l(archive_date, :format => '%Y')
          @posts = Post.live.by_year(archive_date).page(params[:page])
        end
        respond_with (@posts)
      end

      def tagged
        @tag = ActsAsTaggableOn::Tag.find(params[:tag_id])
        @tag_name = @tag.name
        @posts = Post.live.tagged_with(@tag_name).page(params[:page])
      end

    private

    protected
      def canonical?
        Refinery::I18n.default_frontend_locale != Refinery::I18n.current_frontend_locale
      end
    end
  end
end
