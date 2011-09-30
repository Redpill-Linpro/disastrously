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

namespace :disastrously do
  namespace :deliver do

    desc 'Deliver anything presently queued in the deliveries table.'
    task :all => :environment do
      files = Dir[File.join File.dirname(__FILE__), "*.rake"]
      files.map! {|f| f.split("/").last.sub(/\.rake$/, "") }
      files -= %w(all status)

      files.each do |name|
        task = %(disastrously:deliver:#{name})
        puts %(Executing %s ...) % task
        Rake::Task[task].execute
      end
    end
  end

end