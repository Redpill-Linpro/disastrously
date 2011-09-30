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

namespace :db do
  namespace :backup do

    desc "Create production dump and restore to given environment (stage=environment)."
    task :restore_from_prod do
      unless stage = ENV['stage']
        abort "Need stage to restore database to, e.g. 'rake #{ARGV.join ' '} stage=staging'"
      end

      puts "", "Creating backup from production..."
      cmd = "cap production db:backup:create"
      puts cmd
      system cmd

      abort unless $? == 0

      puts "", "Restoring backup to '#{stage}' environment..."

      filename = Dir["*.production.pgdump"].sort.last

      if stage == "development"
        cmd = "rake db:backup:restore name=#{filename}"
        puts cmd
        system cmd

      else
        cmd = [] << "cap"
        cmd << stage
        cmd << "db:backup:restore"

        cmd << "name=#{filename}"

        puts cmd.join(' ')
        system cmd.join(' ')
      end
    end

  end
end