Refinery::User.all.each do |user|
  if user.plugins.where(:name => 'refinerycms_seoblog').blank?
    user.plugins.create(:name => "refinerycms_seoblog",
                        :position => (user.plugins.maximum(:position) || -1) +1)
  end
end if defined?(Refinery::User)

if defined?(Refinery::Page) and !Refinery::Page.exists?(:link_url => '/blog')
  page = Refinery::Page.create(
    :title => "Blog",
    :link_url => "/blog",
    :deletable => false,
    :menu_match => "^/blogs?(\/|\/.+?|)$"
  )

  Refinery::Pages.default_parts.each_with_index do |default_page_part, index|
    page.parts.create(:title => default_page_part, :body => nil, :position => index)
  end
end
