# encoding: utf-8
require 'spec_helper'

describe "Categories admin", type: :feature do
  refinery_login_with :refinery_user

  let(:title) { "lol" }

  it "can create categories" do
    visit refinery.admin_root_path

    within("nav#menu") { click_link "Blog" }
    within("nav.multilist") { click_link "Create new category" }

    fill_in "Title", :with => title
    click_button "Save"

    category = Refinery::Blog::Category.first
    expect(category.title).to eq(title)
  end

  context "with translations" do
    before do
      allow(Refinery::I18n).to receive(:frontend_locales).and_return([:en, :it])
      blog_page = Globalize.with_locale(:en) { FactoryGirl.create(:page, :link_url => "/blog", :title => "Blog") }
      Globalize.with_locale(:it) do
        blog_page.title = 'блог'
        blog_page.save
      end
    end

    describe "add a category with title for default locale" do
      before do
        Globalize.locale = :en
        visit refinery.blog_admin_posts_path
        click_link "Create new category"
        fill_in "Title", :with => "Testing Category"
        click_button "Save"
        @c = Refinery::Blog::Category.find_by_title("Testing Category")
      end

      it "suceeds" do
        expect(page).to have_content("'#{@c.title}' was successfully added.")
        expect(Refinery::Blog::Category.count).to eq(1)
      end

      it "shows locale flag for category" do
        click_link "Manage"
        within "#category_#{@c.id}" do
          expect(page).to have_css("img[src='/assets/refinery/icons/flags/en.png']")
        end
      end

      it "shows up in blog page for default locale" do
        visit refinery.blog_root_path
        within "#categories" do
          expect(page).to have_selector('li')
        end
      end

      it "does not show up in blog page for secondary locale" do
        visit refinery.blog_root_path(:locale => :it)
        expect(page).not_to have_selector('#categories')
      end

    end

    describe "add a category with title for secondary locale" do

      let(:it_category_title) { 'Categoria di Prova' }

      before do
        visit refinery.blog_admin_posts_path
        click_link "Create new category"
        within "#switch_locale_picker" do
          click_link "it"
        end
        fill_in "Title", :with => it_category_title
        click_button "Save"
        @c = Refinery::Blog::Category.find_by_title(it_category_title)
      end

      it "suceeds" do
        expect(page).to have_content("'#{@c.title}' was successfully added.")
        expect(Refinery::Blog::Category.count).to eq(1)
      end

      it "shows locale flag for category" do
        click_link "Manage"
        within "#category_#{@c.id}" do
          expect(page).to have_css("img[src='/assets/refinery/icons/flags/it.png']")
        end
      end

      it "does not show locale flag for primary locale" do
        click_link "Manage"
        within "#category_#{@c.id}" do
          expect(page).not_to have_css("img[src='/assets/refinery/icons/flags/en.png']")
        end
      end

      it "does not shows up in blog page for default locale" do
        visit refinery.blog_root_path
        expect(page).not_to have_selector('#categories')
      end

      it "shows up in blog page for secondary locale" do
        visit refinery.blog_root_path(:locale => :it)
        within "#categories" do
          expect(page).to have_selector('li')
        end
      end


    end


  end
end
