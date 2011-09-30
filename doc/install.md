# Installing Disastrously

This document describes general setup of development and production
environment, and general deployment routine.

This project uses [Bundler][] as gem management tool instead of the built in
tools in Rails 2.3 (Rails 3 uses Bundler by default).

[Bundler]: http://gembundler.com

The dependencies needed by this project is listed in the file Gemfile.


# All environments - Bootstrapping

Some Ruby infrastucture is needed on your development/production machine
(assuming Ubuntu):

1.  Install Ruby and some libraries:

        $ sudo apt-get install ruby1.8 ruby1.8-dev libreadline-ruby1.8 libopenssl-ruby1.8

    The ruby1.8-dev package is required to build the native extension for
    postgres.

2.  Install Rubygems:

    1.  Download the rubygems package (http://rubygems.org/pages/download):

            $ wget http://production.cf.rubygems.org/rubygems/rubygems-1.7.2.tgz

    2.  Install it:

            $ tar xzvf rubygems-1.7.2.tgz
            $ cd rubygems-1.7.2
            $ sudo setup.rb

    The rubygems package in ubuntu is unfortunately so old that we can't use
    it.

3.  Install Bundler:

        $ sudo gem install bundler

Now that the Ruby environment is up and running, you can setup the database
(assuming postgres):

4.  Create a db user for postgres:

    Using **postgresql** is highly recommended (since Redpill Linpro staging
    and production uses it):

        $ sudo su postgres -c psql
        postgres=# create role rl with password 'somepassword' login createdb;
        CREATE ROLE
        postgres=# \q

5.  Create config files:

        $ cp config/notification.yml.example config/notification.yml
        $ cp config/database.yml.example config/database.yml
        $ cp config/email.yml.example config/email.yml

6.  Setup config files.

    Edit the following files appropriately:

    config/database.yml:

    :   This file contains the database settings. The production settings are
        used by passenger. Edit this file and insert the correct
        username and password.

    email.yml:

    :   This file contains the email configuration (configuration for sending mail).

    notification.yml:

    :   This file contains some mail addresses used when sending out mail, e.g.
        default reply to. It can also contain a cc and/or bcc address, which will be
        added upon all mails sendt from the system.


# Developers

## Setup

Follow "All environments - Bootstrapping" above, and then do the following:

1.  To setup your environment, run:

        $ bundle install --local --system

    The --local switch tells bundler to use the gems found in vendor/cache if
    appropriate (saves you some time and bandwidth). The --system switch tells
    bundler to install the gems system wide.

2.  Setup database (follow the instructions):

        $ rake db:setup

3.  Setup test-database:

        $ rake db:test:prepare

4.  Run the tests to verify that everything works:

        $ rake


## Development

Developers add the gems they need into the Gemfile. Then, run the following to
install the gem and its dependencies system wide:

    $ bundle install --system

This creates or updates a Gemfile.lock file. This file contains the exact
version numbers for all the gems you are using, including dependencies. When
you or anyone else executes "bundle install" bundler will use the version
numbers from the Gemfile.lock file, which ensures that everyone is using the
exact same gems.

Commit the updated Gemfile and Gemfile.lock to version control.

For help using bundler:

    $ bundle --help
    $ bundle --help install # or any other command


## Tests

Run the tests! Don't commit code that breaks the tests!

Also, run "rake spec:rcov" to make sure that the code you've written is covered
by the tests. If it isn't, write tests!

Tip: You can save some time running the tests by skipping the drop/create of
the test database. Just run "spec spec/" instead of "rake". (This will over
time fill up the test database, making the tests run slower than usual. Run
"rake" to drop/recreate it in those cases.)

In general when hacking on this project: Try to intermittently change between
writing new features and cleaning up old code. Since there's no one actively
maintaining the code, someone needs to upgrade and maintain it to prevent it
from bit rotting. And since you're reading this, that someone is YOU! :-)


## Preparing for production

In order to copy the gems into vendor/cache, run the following:

    $ bundle pack

And finally commit vendor/cache into version control. By having the gems in the
version control system, the production system doesn't need to go online to
fetch them.


# Sysops

## Preparing for production

Please follow "All environments - Bootstrapping" above.

In addition:

1.  Make sure the environment variable `RAILS_ENV` is "production" for the
    deployment user (e.g. by putting `RAILS_ENV=production` in .bashrc or
    something).

    This is needed in case e.g. a rake command is executed by the deploy user
    which differs in action depending on the environment.

2.  Create the production database. You can do it the "Rails way" by simply
    issuing:

        $ rake db:setup

    The configuration found in config/database.yml will be used by Rails to
    create the database.

3.  Setup the webserver. This is out of scope for this document, but
    [phusion passenger][] (modrails) on apache is probably the preferred way.

    See [this][modrails_doc] for instructions (if setting up staging, remember to set
    RAILSENV to "staging" for the webserver also).

    [phusion_passenger]: http://www.modrails.com

    [modrails_doc]: http://www.modrails.com/documentation/Users%20guide%20Apache.html#_deploying_a_ruby_on_rails_application


# Deployment

## Automatic {#automatic}

This project uses [Capistrano][] as deployment tool. In order to deploy, you
need the files in the code repository locally.

[Capistrano]: https://github.com/capistrano/capistrano

1.  Either:

    -   Fetch a copy of the code:

        `git clone url`

        OR

        `git archive --remote=ssh://url ref | tar x`

        Where "url" is the URL to the projects main git repository and "ref" is
        any kind of git ref (e.g. a branch name like "master" or "staging", or a
        tag like "HEAD" or "vX.Y.Z"). Using a tagname is probably a good idea.

    OR

    -   Update the code:

        If you have an earlier clone of the repository, you can simply fetch new
        changes instead of cloning it again:

            $ git pull

2.  Install capistrano:

        $ sudo gem install capistrano capistrano-ext

3.  Deploy:

    A)  To staging:

            $ cap staging deploy:migrations tag=vX.Y.Z

    B)  To production:

            $ cap production deploy:migrations tag=vX.Y.Z


Background info:

During a deploy capistrano will log in to the relevant machine (e.g. staging)
and clone the git repository from the authoritative source before checking out
the relevant branch/tag given on the command line.

Therefore, you don't actually need a copy of what you're deploying locally. The
only reason we need the files in the code repository locally is to get a hold
of the capistrano config files so that capistrano knows how to deploy. The
config files might change if it's needed, so it's wise to use the config files
from the tag/branch you're deploying.

We use "deploy:migrations" instead of simply "deploy" in order to run any new
[migrations][]. If there aren't any new migrations, it will simply deploy as
normal.

[migrations]: http://guides.rubyonrails.org/migrations.html


## Manual

1.  Follow step 1 from [Automatic](#automatic) above.

2.  Install dependencies:

    Even though the gems needed by the project is located in vendor/cache, they
    still need to be installed. Bundler has a built in deployment mode suitable
    for this:

        $ bundle install --deployment

    This installs the gems found in vendor/cache.

3.  Run migrations if any:

        $ rake db:migrate

If everything went OK the project is now properly installed and ready to be
used.

If the webserver is setup with apache and phusion passenger, a simple "touch
tmp/restart.txt" should be enough to finish the deployment.

