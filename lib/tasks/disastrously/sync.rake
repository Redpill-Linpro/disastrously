# Copyright 2011 Redpill-Linpro AS.
#
# This file is part of Disastrously.
#
# Disastrously is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# Disastrously is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Disastrously. If not, see <http://www.gnu.org/licenses/>.

#
# Synchronize data from external authoritative sources.
#
# See lib/disastrously/sync.rb for more information.
#
namespace :disastrously do
  namespace :sync do

    desc %(Synchronize customers, customer groups and users from LDAP.)
    task :from_ldap => :environment do
      # Upon creating a new project, disastrously:install rake task needs to be
      # executed to add e.g. support for Bundler (to Rails 2.3). This allows
      # gems from the Gemfile to be properly loaded (which is how Disastrously
      # gets loaded).
      #
      # Before this is done, the file 'disastrously/sync' is not visible to
      # Rails (or rake), which is why we must require it inside the task
      # instead of outside it.
      require 'disastrously/sync'

      config_file = Rails.root.join(Disastrously::Sync::CONFIG_FILE)
      config = YAML.load(IO.read config_file)[:from_ldap].freeze

      Disastrously::Sync::FromLDAP.new(config).run!
    end

  end
end