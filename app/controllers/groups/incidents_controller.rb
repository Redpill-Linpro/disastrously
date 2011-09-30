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

class Groups::IncidentsController < DisastrouslyController
  before_filter :authenticate
  before_filter :check_group_name, :set_title

  include Shared::ActiveScaffoldDefaults
  include Shared::ActiveScaffoldAuthorization

  # This controller was originally only meant to be used by users to create new
  # incidents for one particular group, but since an incident can have multiple
  # groups now, it's basically a slightly trimmed version of admin/incidents.
  active_scaffold :incidents do |config|
    default(config, :list, :show, :create, :update, :search, :subform)
  end

  private

  def set_title
    active_scaffold_config.list.label = "Incidents for #{params[:group_name]}"
  end

  def check_group_name
    if not @group_name = params[:group_name] or not Group.find_by_name(@group_name)
      use_layout = (not request.xhr?)
      render :partial => "shared/box", :locals => { :msg => "Found no group with name #{@group_name}." }, :layout => use_layout
    end
  end

  def conditions_for_collection
    if group = Group.find_by_name(params[:group_name])
      ['incident_to_groups.group_id = ? AND incidents.parent_id IS NULL', group.id]
    end
  end

  # these are used by active scaffold to control access:
  def create_authorized?
    current_user.user_type.admin_access? or current_user.user_type.create_group_incidents?
  end

  def update_authorized?
    true
  end

end