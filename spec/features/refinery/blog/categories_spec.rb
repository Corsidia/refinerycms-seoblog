require "spec_helper"

module Refinery
  describe "BlogCategories", type: :feature do
    refinery_login_with :refinery_user

    context "has one category and post" do
      before do
        @category = Globalize.with_locale(:en) do
          FactoryGirl.create(:blog_category, :title => "Video Games")
        end
        post = Globalize.with_locale(:en) do
          FactoryGirl.create(:blog_post, :title => "Refinery CMS blog post", category: @category)
        end
        post.save!
      end

      describe "show categories blog posts" do
        it "should displays categories blog posts" do
          visit refinery.blog_category_path(@category)
          expect(page).to have_content("Refinery CMS blog post")
          expect(page).to have_content("Video Games")
        end
      end
    end
  end
end
