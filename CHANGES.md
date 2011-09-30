## plugin

* Major feature: Convert Disastrously to plugin.

  This allows Disastrously to be reused with different configurations with
  ease.

* Add disastrously:install rake task which properly installs disastrously as a
  plugin.

* Add disastrously:seed:example which adds example seed data.

* Misc cleanup. Move shared controllers/helpers/models from lib to app.

* Activate Ruby 1.9 code when using Ruby 1.9 (e.g. encoding).

## staging

## v2.1.3 - 2011.09.29

* Fix nil-bug in SLA handling.
* Fix disastrously:sync:from_ldap config (config/sync.yml).

## v2.1.2 - 2011.09.28

* Several bugfixes related to deliveries and disastrously:deliver:email rake
  task.

* Add Notifier#raw method.

* Several improvements to app/views/admin/deliveries/_message template.

## v2.1.1 - 2011.09.28

* Fix Group#all_member_of_incident, thus fixing incident export.
* Gemfile: Add missing dependency for disastrously:sync:from_ldap rake task.
* rspec.rake: Remove Rake::DSL until a permanent fix can be found.

## v2.1.0 - 2011.09.27

* Add disastrously:deliver:status rake task which outputs number of unprocessed
  deliveries.

* Add disastrously:deliver:{all,email} rake tasks which executes deliver! on
  all deliveries with delivered_at = nil (thus enabling asynchron delivery via
  e.g. cron).

* Add disastrously:sync:from_ldap rake task which updates the database with
  user, customer and membership info from LDAP.

* Add deliver! method to Delivery instances which performs the delivery and
  updates state.

* Fix handling of repository in deployment rake task.

  Disastrously uses a special deploy prosedure since it's assumed that
  production doesn't have access to the server where the repository is stored.

* Fix db:backup:create/restore: Use bundler.

* Update rake from 0.8.7 to 0.9.2.

## v2.0.5 - 2011.08.29

* Fix empty strings as values in group model (convert to nil before
  validation).
* Fix seeds.rb.

## v2.0.4 - 2011.08.19

* Show timestamps in incident show view.
* Show description paragraph in incident list view where possible.
* Update/fix deployment code.

## v2.0.3 - 2011.08.16

* Fix exception notifier config.
* Fix migration bitrot.

## v2.0.2 - 2011.07.16

* Added some documentation written in Markdown and make_doc.rb script.
* Select all/none/invert in admin/users.
* Don't show children incidents in incident lists (for all controllers).
* Some code cleanup.

## v2.0.1 - 2011.07.07

* Fix tests.
* Support date and patch version in APP_VERSION.

## v2.0 - 2011.07.06

* Major feature: Add support for Incident Children.

  Each incident may now have one or more children incidents which are used to
  override certain fields in the main incident.

## v1.8.3 - 2011.07.06

* Several CSS improvements.
* Use CSS3 columns for lists (e.g. header menu).

## v1.8.2 - 2011.07.06

* Add config/version.yml available via APP_VERSION.

## v1.8.1 - 2011.07.06

* Lots of bugfixes and cleanup surrounding active scaffold upgrade.

## v1.8.0 - 2011.07.06

* Feature: Use devops-puppet.git as submodule in puppet-manifests.

## v1.7.0 - 2011.06.09

* Major feature: Added support for multiple timestamps.
* Major feature: Upgraded to Active Scaffold v2.4 (a.k.a. master or edge).

## v1.6.0 - 2011.05.22

* Major feature: Added support for "ongoing incident" and "unknown start".

## v1.5.3 - 2011.05.22

* Upgrade some configuration to Rails 3 format.
* Misc cleanup.

## v1.5.2 - 2011.05.22

* Use timestamped migrations.
* Clean up Vagrantfile.
* Clean up config/environment.rb.

## v1.5.1 - 2011.05.12

* Add puppet scripts.
* Add Vagrantfile.

## v1.5.0 - 2011.05.04

* Replace old exception notifier plugin with new gem.
* Add documentation from wiki.

## v1.4.2 - 2011.05.03

* Better SLA output in development.
* Updated deploy documentation.

## v1.4.1 - 2011.05.02

* Clean up capistrano.

## v1.4.0 - 2011.05.02

* Major feature: Support Incident belonging to multiple groups.

* Upgrade from Rails 2.3.2 to 2.3.11 (latest).
* Use Bundler for gem handling instead of built in Rails support.
* Implement basic tests (ie. catch exceptions) for most of the code.
* Update some code to also handle Ruby 1.9.

## v1.3.9 - 2011.04.07

* Feature: Add CSV export for SLA data.
* Clean up incident helpers.

## v1.3.8 - 2011.04.05

* Feature: Show delivery table in incident form.

## v1.3.7 - 2011.04.04

* Use ISO datetime (YYYY-MM-DD HH:MM) everywhere.

## v1.3.6 - 2011.04.05

* Add basic test setup with rspec, capybara and factory girl.
* Cleanup config/routes.rb.
* Refactor and cleanup.

## v1.3.5 - 2011.03.25

* Reimplement and fix SLA algorithm.

## v1.3.4 - 2011.03.24

* Added RSpec testing framework.

## v1.3.3 - 2010.08.09
## v1.3.2 - 2010.05.25
## v1.3.1 - 2010.05.25
## v1.3.0 - 2010.05.25
## v1.2.0 - 2010.03.12
## v1.1.1 - 2010.03.11
## v1.1.0 - 2010.02.22
## v1.0.1 - 2010.02.19
## v1.0   - 2010.02.16
