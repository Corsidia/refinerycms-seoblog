require "spec_helper"

module Refinery
  describe "Blog::Posts", type: :feature do
    refinery_login_with :refinery_user

    context "when has blog posts" do
      let!(:blog_post) do
        Globalize.with_locale(:en) { FactoryGirl.create(:blog_post, :title => "Refinery CMS blog post") }
      end

      it "should display blog post" do
        visit refinery.blog_post_path(blog_post.category, blog_post)

        page.should have_content(blog_post.title)
      end

      describe "visit blog" do

        before do
          FactoryGirl.create(:page, :link_url => "/")
          FactoryGirl.create(:page, :link_url => "/blog", :title => "Blog")
        end

        it "shows blog link in menu" do
          visit "/"
          within "#menu" do
            page.should have_content("Blog")
            page.should have_selector("a[href='/blog']")
          end
        end

        it "shows blog posts" do
          visit refinery.blog_root_path
          page.should have_content blog_post.title
        end

      end

    end

    describe "list tagged posts" do
      context "when has tagged blog posts" do
        before do
          @tag_name = "chicago"
          @post = FactoryGirl.create(:blog_post,
                                          :title => "I Love my city",
                                          :tag_list => @tag_name)
          @tag = ::Refinery::Blog::Post.tag_counts_on(:tags).first
        end
        it "should have one tagged post" do
          visit refinery.blog_tagged_posts_path(@tag.id, @tag_name.parameterize)

          page.should have_content(@tag_name)
          page.should have_content(@post.title)
        end
      end
    end

    describe "#show" do

      context "post popular" do
        let(:blog_post) { FactoryGirl.create(:blog_post) }
        let(:blog_post2) { FactoryGirl.create(:blog_post) }

        before do
          visit refinery.blog_post_path(blog_post.category, blog_post)
        end

        it "should increment access count" do
          blog_post.reload.access_count.should eq(1)
          visit refinery.blog_post_path(blog_post.category, blog_post)
          blog_post.reload.access_count.should eq(2)
        end

        it "should be most popular" do
          Refinery::Blog::Post.popular(2).first.should eq(blog_post)
        end
      end

      context "post recent" do
        let!(:blog_post) { FactoryGirl.create(:blog_post, :published_at => Time.now - 5.minutes) }
        let!(:blog_post2) { FactoryGirl.create(:blog_post, :published_at => Time.now - 2.minutes) }

        it "should be the most recent" do
          Refinery::Blog::Post.recent(2).first.id.should eq(blog_post2.id)
        end
      end

    end

    describe "#show draft preview" do
      let(:blog_post) { FactoryGirl.create(:blog_post_draft) }

      context "when logged in as admin" do
        it "should display the draft notification" do
          visit refinery.blog_post_path(blog_post.category, blog_post)

          page.should have_content('This page is NOT live for public viewing.')
        end
      end

      context "when not logged in as an admin" do
        before do
          # TODO: remove Refinery::Pages::Engine.load_seed dependency.
          # It's here to temporary fix the issue with 404 after visiting logout path.
          Refinery::Pages::Engine.load_seed
          visit refinery.logout_path
        end

        it "should not display the blog post" do
          visit refinery.blog_post_path(blog_post.category, blog_post)

          page.should have_content("The page you requested was not found.")
        end
      end
    end
  end
end
