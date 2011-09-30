= Creating a new Disastroulsy project

== Create a new Rails project

1.  Install bundler:

    gem install bundler

2.  Create a Gemfile in a new directory:

    bundle init

3.  Add this to the Gemfile:

    gem "rails", "~> 2.3.11"

4.  Run bundler:

    bundle install

5.  Setup new rails project:

    bundle exec rails .

6.  Setup database access:

    Create e.g. a postgres role and add necessary information to
    config/database.yml.

== Install Disastrously

7.  Add disastrously plugin:

    git clone git@github.com:redpill-linpro/disastrously.git vendor/plugins/disastrously

8.  Add to Gemfile:

    gem "disastrously", :path => "vendor/plugins/disastrously"

9.  Run bundler to fetch disastrously dependencies:

    bundle install

10. Install disastrously plugin:

    bundle exec rake disastrously:install

11. Setup database:

    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake disastrously:seed

12. That's it!

    ./script/server

