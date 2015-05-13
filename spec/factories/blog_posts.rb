FactoryGirl.define do
  factory :blog_post, :class => Refinery::Blog::Post do
    sequence(:title) { |n| "Top #{n} Shopping Centers in Chicago" }
    body "These are the top ten shopping centers in Chicago. You're going to read a long blog post about them. Come to peace with it."
    draft false
    sticky false
    association :category, factory: :blog_category, strategy: :build
    published_at Time.now
    author { FactoryGirl.create(:refinery_user) }

    factory :blog_post_draft do
      draft true
    end

    factory :blog_post_sticky do
      sticky true
    end
  end
end
