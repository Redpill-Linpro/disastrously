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

class IncidentsController < DisastrouslyController
  before_filter :authenticate

  include Shared::ActiveScaffoldDefaults
  include Shared::ActiveScaffoldAuthorization

  # This controller is only meant to be used by users to create new incidents.
  active_scaffold :incident do |config|
    default(config, :create, :subform)
  end

  def index
    # Active Scaffold will hit this action after creating an incident.
    redirect_to root_url
  end

  def list
    # Active Scaffold will hit this action when a user chooses cancel.
    redirect_to root_url
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