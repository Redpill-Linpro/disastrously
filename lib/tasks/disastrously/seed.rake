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

plugin_root = File.expand_path(__FILE__) =~ %r|^(.*)/lib/tasks/| && $1

namespace :disastrously do

  desc 'Load generic/bootstrap seed data from disastrously/db/seeds.rb'
  task :seed => :environment do
    seed_file = File.join(plugin_root, 'db', 'seeds.rb')
    load(seed_file)
  end

  namespace :seed do
    desc 'Load example seed data.'
    task :example => :environment do
      seed_file = File.join(plugin_root, 'db', 'example_seeds.rb')
      load(seed_file)
    end
  end

end