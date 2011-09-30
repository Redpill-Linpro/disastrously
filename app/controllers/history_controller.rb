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

class HistoryController < DisastrouslyController
  before_filter :authenticate

  # The history controller is only meant to show the history for a
  # particular user. Both config/routes and active scaffold have
  # disabled anything other than list/show.
  active_scaffold :histories do |config|
    config.actions = %w{list show search}

    # add virtual columns (columns from associations)
    config.columns << %w{groups handled_by started_at ended_at description severity sla_time service_window_time created_by created_at updated_by updated_at}

    config.list.columns = %w{
      parent
      incident
      groups
      handled_by
      severity
      description
      started_at
      ended_at
      sla_time
      service_window_time
    }

    config.show.columns = %w{incident groups handled_by started_at ended_at complete_description severity sla_time service_window_time created_by created_at updated_by updated_at}

    config.columns[:user].form_ui = :select
    config.columns[:incident].form_ui = :select

    config.columns[:groups].form_ui = :select
    config.columns[:handled_by].form_ui = :select
    config.columns[:severity].form_ui = :select

    config.columns[:incident].label = "Title"
    config.columns[:sla_time].label = "SLA time"
    config.columns[:service_window_time].label = "Planned downtime"
    config.columns[:started_at].label = "Start time"
    config.columns[:ended_at].label = "End time"

    config.list.per_page = 50
    config.list.label = "Personal History"

    config.list.sorting = [ { :ended_at => :desc }, { :started_at => :desc }, { :created_at => :desc } ]
  end

  private

  def conditions_for_collection
    ["user_id IN (?) AND incidents.parent_id IS NULL", current_user.id]
  end

end