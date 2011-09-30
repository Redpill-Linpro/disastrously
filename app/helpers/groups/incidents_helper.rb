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

module Groups::IncidentsHelper

  include Shared::IncidentsFormHelper

  alias :old_groups_form_column :incident_groups_form_column

  def incidents_groups_form_column(record, input_name)
    if record.new_record? and @group_name and not record.group_checkboxes
      record.group_checkboxes = { "0" => {"id" => Group.find_by_name(@group_name).id } }
    end

    old_groups_form_column(record, input_name)
  end

end