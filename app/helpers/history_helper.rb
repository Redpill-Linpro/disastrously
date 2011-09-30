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

module HistoryHelper
  # We can't use the IncidentFormHelper module here, since the incident is
  # reached via record.incident instead of directly from record.

  include Shared::IncidentsFormHelper

  def history_complete_description_column(record)
    incident_complete_description_column(record.incident)
  end

  def history_started_at_column(record)
    incident_started_at_column(record.incident)
  end

  def history_ended_at_column(record)
    incident_ended_at_column(record.incident)
  end

  def history_created_at_column(record)
    incident_created_at_column(record.incident)
  end

  def history_updated_at_column(record)
    incident_updated_at_column(record.incident)
  end

  def history_sla_time_column(record)
    incident_sla_time_column(record.incident)
  end

  def history_service_window_time_column(record)
    incident_service_window_time_column(record.incident)
  end

  # History specific:

  def history_parent_column(record)
    record.incident.parent.title if record.incident.parent
  end

  def history_groups_column(record)
    # TODO: Create link to groups.
    record.incident.groups.map {|g| g.name}.join(", ")
  end

  def history_handled_by_column(record)
    record.incident.handled_by.username if record.incident.handled_by
  end

  def history_severity_column(record)
    record.incident.severity.title if record.incident.severity
  end

  def history_description_column(record)
    record.incident.description
  end

  def history_created_by_column(record)
    record.incident.created_by.username if record.incident.created_by
  end

  def history_updated_by_column(record)
    record.incident.updated_by.username if record.incident.updated_by
  end

end