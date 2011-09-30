# Development Workflow

Disastrously uses [Capistrano](http://capify.org) as deployment/remote access
tool. You need capistrano installed locally to do e.g. a deployment:

    $ gem install capistrano


## Development commands

`rake -T`

:   Lists all available rake commands.

`rake db:backup:create`

:   Create database backup.

`rake db:backup:restore file=some_file.pgdump`

:   Restore database from given file.

*Note: The next commands execute capistrano to do things remotely. That's why
you always run these commands locally, on your development machine.*

`rake db:backup:restore_from_prod stage=dev`

:   Executes capistrano which creates a backup of the database in production,
    downloads it locally, then uses **rake** to restore the backup to your
    local database (all in a single command).

`rake db:backup:restore_from_prod stage=staging`

:   Same as above, except it fires up capistrano to restore the database on
    **staging** instead of locally.

## Deployment commands

The first non-option argument to cap sets the stage (machine) the commands are
executed on. Choose **staging** or **production** for any of these
commands.

`cap -T`

:   Lists all available capistrano commands.

`cap staging deploy`

:   Log in to staging and deploy the latest code from the **staging** branch.

`cap staging deploy:migrations`

:   Log in to staging and deploy the latest code from the **staging** branch
    and run any available migrations.

`cap production deploy:migrations`

:   Log in to production and deploy the latest code from the **master** branch
    and run any available migrations.

`cap production deploy:restart`

:   I've noticed that deploying sometimes doesn't trigger a restart of
    mod\_passenger. If there is are strange code errors after a deploy, issue this
    command to force a new mod\_passenger restart.

:   *Replace* **production** *with* **staging** *for staging.*

`cap production deploy:rollback`

:   If you ever find yourself doing a bad deploy you can easily rollback to the
    previous deployment by running this command. That task will revert to a
    previous rollback and restart the server.

:   **This should be used with caution if there are migrations involved.**

:   *Replace* **production** *with* **staging** *for staging.*

