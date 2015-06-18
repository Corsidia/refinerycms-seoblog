require "spec_helper"
module Refinery
  module Blog

    describe "/blog/:slug", :type => :routing do
      routes { Refinery::Core::Engine.routes }

      it "is routed to a category" do
        expect(:get => '/blog/category-name').
        to route_to(:controller => "refinery/blog/categories",
                    :action => "show",
                    :slug => "category-name",
                    :locale => :en)
      end
    end
  end
end