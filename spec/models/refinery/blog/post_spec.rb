require 'spec_helper'

module Refinery
  module Blog
    describe Post, type: :model do
      let(:post) { FactoryGirl.create(:blog_post) }

      describe "validations" do
        it "requires title" do
          FactoryGirl.build(:blog_post, :title => "").should_not be_valid
        end

        it "won't allow duplicate titles" do
          FactoryGirl.build(:blog_post, :title => post.title).should_not be_valid
        end

        it "requires body" do
          FactoryGirl.build(:blog_post, :body => nil).should_not be_valid
        end

        it "won't allow uncategorized posts" do
          expect(FactoryGirl.build(:blog_post, :category => nil)).not_to be_valid
        end
      end

      describe "categories association" do
        it "have category attribute" do
          post.should respond_to(:category)
        end
      end

      describe "tags" do
        it "acts as taggable" do
          post.should respond_to(:tag_list)

          post.tag_list = "refinery, cms"
          post.save!

          post.tag_list.should include("refinery")
        end
      end

      describe "authors" do
        it "are authored" do
          described_class.instance_methods.map(&:to_sym).should include(:author)
        end
      end

      describe "by_month" do
        before do
          @post1 = FactoryGirl.create(:blog_post, :published_at => Date.new(2011, 3, 11))
          @post2 = FactoryGirl.create(:blog_post, :published_at => Date.new(2011, 3, 12))

          #2 months before
          FactoryGirl.create(:blog_post, :published_at => Date.new(2011, 1, 10))
        end

        it "returns all posts from specified month" do
          #check for this month
          date = "03/2011"
          described_class.by_month(Time.parse(date)).count.should be == 2
          described_class.by_month(Time.parse(date)).should == [@post2, @post1]
        end
      end

      describe ".published_dates_older_than" do
        before do
          @post1 = FactoryGirl.create(:blog_post, :published_at => Time.utc(2012, 05, 01, 15, 20))
          @post2 = FactoryGirl.create(:blog_post, :published_at => Time.utc(2012, 05, 01, 15, 30))
          FactoryGirl.create(:blog_post, :published_at => Time.now)
        end

        it "returns all published dates older than the argument" do
          expected = [@post2.published_at, @post1.published_at]

          described_class.published_dates_older_than(5.minutes.ago).should eq(expected)
        end
      end

      describe "live" do
        before do
          @post1 = FactoryGirl.create(:blog_post, :published_at => Time.now.advance(:minutes => -2))
          @post2 = FactoryGirl.create(:blog_post, :published_at => Time.now.advance(:minutes => -1))
          FactoryGirl.create(:blog_post, :draft => true)
          FactoryGirl.create(:blog_post, :published_at => Time.now + 1.minute)
        end

        it "returns all posts which aren't in draft and pub date isn't in future" do
          live_posts = described_class.live
          live_posts.count.should be == 2
          live_posts.should include(@post2)
          live_posts.should include(@post1)
        end
      end

      describe "#live?" do
        it "returns true if post is not in draft and it's published" do
          FactoryGirl.build(:blog_post).should be_live
        end

        it "returns false if post is in draft" do
          FactoryGirl.build(:blog_post, :draft => true).should_not be_live
        end

        it "returns false if post pub date is in future" do
          FactoryGirl.build(:blog_post, :published_at => Time.now.advance(:minutes => 1)).should_not be_live
        end
      end

      describe "#next" do
        before do
          FactoryGirl.create(:blog_post, :published_at => Time.now.advance(:days => -1))
          @post = FactoryGirl.create(:blog_post)
        end

        it "returns next article when called on current article" do
          described_class.newest_first.last.next.should == @post
        end
      end

      describe "#prev" do
        before do
          FactoryGirl.create(:blog_post)
          @post = FactoryGirl.create(:blog_post, :published_at => Time.now.advance(:days => -1))
        end

        it "returns previous article when called on current article" do
          described_class.first.prev.should == @post
        end
      end

      describe "custom teasers" do
        it "should allow a custom teaser" do
          FactoryGirl.create(:blog_post, :custom_teaser => 'This is some custom content').should be_valid
        end
      end

      describe ".teasers_enabled?" do
        context "with Refinery::Setting teasers_enabled set to true" do
          before do
            Refinery::Setting.set(:teasers_enabled, { :scoping => 'blog', :value => true })
          end

          it "should be true" do
            described_class.teasers_enabled?.should be_truthy
          end
        end

        context "with Refinery::Setting teasers_enabled set to false" do
          before do
            Refinery::Setting.set(:teasers_enabled, { :scoping => 'blog', :value => false })
          end

          it "should be false" do
            described_class.teasers_enabled?.should be_falsey
          end
        end
      end

      describe "source url" do
        it "should allow a source url and title" do
          p = FactoryGirl.create(:blog_post, :source_url => 'google.com', :source_url_title => 'author')
          p.should be_valid
          p.source_url.should include('google')
          p.source_url_title.should include('author')
        end
      end

      describe ".validate_source_url?" do
        context "with Refinery::Blog.validate_source_url set to true" do
          before do
            Refinery::Blog.validate_source_url = true
          end
          it "should have canonical url" do
            UrlValidator.any_instance.should_receive(:resolve_redirects_verify_url).
                                      and_return('http://www.google.com')
            p = FactoryGirl.create(:blog_post, :source_url => 'google.com', :source_url_title => 'google')
            p.source_url.should include('www')
          end
        end
        context "with Refinery::Blog.validate_source_url set to false" do
          before do
            Refinery::Blog.validate_source_url = false
          end
          it "should have original url" do
            p = FactoryGirl.create(:blog_post, :source_url => 'google.com', :source_url_title => 'google')
            p.source_url.should_not include('www')
          end
        end
      end

      describe "#should_generate_new_friendly_id?" do
        context "when custom_url changes" do
          it "regenerates slug upon save" do
            post = FactoryGirl.create(:blog_post, :custom_url => "Test Url")

            post.custom_url = "Test Url 2"
            post.save!

            expect(post.slug).to eq("test-url-2")
          end
        end

        context "when title changes" do
          it "regenerates slug upon save" do
            post = FactoryGirl.create(:blog_post, :title => "Test Title")

            post.title = "Test Title 2"
            post.save!

            expect(post.slug).to eq("test-title-2")
          end
        end
      end

    end
  end
end
