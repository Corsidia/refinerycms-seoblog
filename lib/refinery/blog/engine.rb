module Refinery
  module Blog
    class Engine < Rails::Engine
      include Refinery::Engine

      isolate_namespace Refinery::Blog

      before_inclusion do
        Refinery::Plugin.register do |plugin|
          plugin.pathname = root
          plugin.name = "refinerycms_seoblog"
          plugin.url = proc { Refinery::Core::Engine.routes.url_helpers.blog_admin_posts_path }
          plugin.menu_match = %r{refinery/blog/?(posts|comments|categories)?}
        end

        Rails.application.config.assets.precompile += %w(
          refinery/blog/backend.css
          refinery/blog/**/*.css
        )
      end

      config.after_initialize do
        Refinery.register_engine(Refinery::Blog)
      end
    end
  end
end
