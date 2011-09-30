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
# This controller is not accessed directly, it is used in AJAX calls from
# incident controllers in create/update forms for incidents.
#
class IncidentTimestampsController < DisastrouslyController

  active_scaffold :incident_timestamps do |config|

    config.create.columns = %w(datetime sla service_window comment)
    config.update.columns = %w(datetime sla service_window comment)

    config.columns[:sla].label              = "SLA"
    config.columns[:sla].form_ui            = :checkbox

    config.columns[:service_window].form_ui = :checkbox
  end

end