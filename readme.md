# Simple SEO Blog for RefineryCMS

This is a simple search engine-optimized blog with a 1-n category-posts association in order to obtain `/blog/category_slug/post_slug` posts' urls and no comment management included.
This project is based on [refinerycms-blog](https://github.com/refinery/refinerycms-blog) and is still in development.

This is the *edge* -and for now the only- version of `refinerycms-seoblog` and it supports only Refinery 3.x and Rails 4.1.x.

<!-- Options:

* [ShareThis.com](http://sharethis.com) support on posts. To enable, set your key in Refinery's settings area. -->

## Requirements

Refinery CMS version 3.0.0 or above.

## Install

Open up your ``Gemfile`` and add at the bottom this line:

```ruby
gem 'refinerycms-seoblog', git: 'https://github.com/darmens/refinerycms-seoblog', branch: 'master'
```

Now, run ``bundle install``

Next, to install the blog plugin run:

    rails generate refinery:blog

Run database migrations:

    rake db:migrate

Finally seed your database and you're done.

    rake db:seed

## Developing & Contributing

The version of Refinery to develop this engine against is defined in the gemspec. To override the version of refinery to develop against, edit the project Gemfile to point to a local path containing a clone of refinerycms.

### Testing

The tests (specs) are being updated...

<!-- Generate the dummy application to test against

    $ bundle exec rake refinery:testing:dummy_app

Run the test suite with [Guard](https://github.com/guard/guard)

    $ bundle exec guard start

Or just with rake spec

    $ bundle exec rake spec -->

## Additional Features
* To limit rss feed length, use the 'max_results' parameter

        http://test.host/blog/feed.rss?max_results=10

## More Information
* Check out the [Refinery Website](http://refinerycms.com/)