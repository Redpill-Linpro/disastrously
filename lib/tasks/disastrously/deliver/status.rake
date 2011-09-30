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

    desc 'Print current status of delivery queue.'
    task :status => :environment do
      puts %(The following number of deliveries are currently queued, grouped by delivery types:)

      DeliveryType.all.map do |type|
        size = Delivery.count(:conditions => { :delivered_at => nil, :delivery_type_id => type.id })
        puts %(  #{type.code}: #{size})
      end

      puts %(Total: %d) % Delivery.count(:conditions => { :delivered_at => nil })
    end

  end
end