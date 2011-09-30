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

class Admin::DeliveriesController < DisastrouslyController
  active_scaffold :deliveries do |config|
    config.actions = [:list, :search, :show]

    config.list.columns = %w{delivery_type recipient incident message updated_by updated_at}
    config.show.columns = %w{delivery_type recipient incident message delivered_at created_by created_at updated_by updated_at}

    config.list.sorting = { :created_at => :desc }
  end

  protected

  def conditions_for_collection
    # only show deliveries that are still in the queue / unprocessed
    ["delivered_at is null"]
  end
end