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

class Admin::IncidentsController < Admin::BaseController

  include Shared::ActiveScaffoldDefaults

  active_scaffold :incidents do |config|
    default(config, :list, :show, :create, :update, :search, :subform)
  end

  private

  def conditions_for_collection
    ['incidents.parent_id IS NULL']
  end

  # these are used by active scaffold to control access:
  def create_authorized?
    current_user.user_type.admin_access? or current_user.user_type.create_group_incidents?
  end

  def update_authorized?
    true
  end

end