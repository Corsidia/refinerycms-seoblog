module Refinery
  module Blog
    module Admin
      class SettingsController < ::Refinery::AdminController

        def teasers
          enabled = Refinery::Blog::Post.teaser_enabled_toggle!
          unless request.xhr?
            redirect_back_or_default(refinery.blog_admin_posts_path)
          else
            render :json => {:enabled => enabled},
                   :layout => false
          end
        end

      end
    end
  end
end