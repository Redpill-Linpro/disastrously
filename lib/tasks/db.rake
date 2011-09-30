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

def get_db_config
  config_file = Rails.root.join 'config', 'database.yml'
  config = YAML.load(IO.read(config_file))

  config[Rails.env] || {}
end

# Useful database rake tasks
namespace :db do

  # Add code to the existing db:schema:load task:
  namespace :schema do
    task :load do
      file = "#{RAILS_ROOT}/db/schema_extra.rb"
      puts "Also loading #{file}..."
      load(file)
    end
  end

  namespace :backup do

    desc "Create dump of database."
    task :create do
      db = get_db_config

      case db["adapter"]
      when "postgresql" then Rake::Task["db:backup:create:postgresql"].invoke
      else
        raise "Adapter #{db["adapter"]} is not supported at the moment."
      end
    end

    namespace :create do
      task :postgresql do
        # This works best if the current user can log into the database
        # automatically.
        db = get_db_config

        cmd = ["pg_dump"]

        if db["host"]
          # production and staging environment differ here a little..
          if Rails.env.production?
            cmd << ["--host", db["host"]] unless db["host"] == "localhost"

          else
            cmd << ["--host", db["host"]]
          end
        end

        cmd << ["--username", db["username"]] if db["username"]
        cmd << db["database"] if db["database"]

        dump_name = [Time.now.strftime('%Y%m%d-%H%M%S'), Rails.env, "pgdump"].join('.')
        cmd << ['>', dump_name]

        puts cmd.join(' ')
        system cmd.join(' ')

        # Return dump name as last line
        puts dump_name
      end
    end

    desc "Restore database from previous dump."
    task :restore do
      db = get_db_config

      case db["adapter"]
      when "postgresql" then Rake::Task["db:backup:restore:postgresql"].invoke
      else
        raise "Adapter #{db["adapter"]} is not supported at the moment."
      end
    end

    namespace :restore do
      task :setup do
        dump_name = ENV['name']

        unless dump_name and File.exists? dump_name
          abort "Can not find '#{dump_name}', please specify database dump with 'name=filename' parameter."
        end

        if Rails.env.production?
          unless ENV['destroy_production'] == "true"
            abort "Use destroy_production=true to actually wipe the production database and restore it from backup."
          end
        end

        # It turns out that the 'drop' and 'create' tasks aren't meant to be
        # executed from another rake task, so they don't return any indication
        # of anything going wrong (no return value and no exception).
        # Therefore, we catch anything that goes to standard error and abort if
        # anything was written there.
        # Note: This doesn't always work for the db:drop task, but should work
        # for db:create.
        begin
          [Rake::Task["db:drop"], Rake::Task["db:create"]].each do |task|
            $stderr = StringIO.new
            Rake::Task[task].invoke
            if $stderr.rewind and msg = $stderr.read
              abort msg if msg.chars.any?
            end
          end
        ensure
          $stderr = STDERR
        end
      end

      task :postgresql => [:setup] do
        # This works best if the current user can log into the database
        # automatically.
        db = get_db_config

        cmd = ["psql"]

        if db["host"]
          # production and staging environment differ here a little..
          if Rails.env.production?
            cmd << ["--host", db["host"]] unless db["host"] == "localhost"
          else
            cmd << ["--host", db["host"]]
          end
        end

        cmd << ["--username", db["username"]] if db["username"]
        cmd << db["database"] if db["database"]

        # The db:restore:setup task makes sure the name env is set
        # (and that the file exists).
        dump_name = ENV['name']
        cmd << ['<', dump_name]

        puts cmd.join(' ')
        system cmd.join(' ')
      end
    end

  end
end