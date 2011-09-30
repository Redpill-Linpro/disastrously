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

class IncidentToGroup < ActiveRecord::Base
  belongs_to :incident
  belongs_to :group

  validates_presence_of   :incident, :group
  validates_uniqueness_of :incident_id, :scope => :group_id

  validate :authorization

  after_create :create_histories

  private

  def authorization
    if not current_user
      # This happens outside a normal requst/response cycle.
      false

    elsif current_user.user_type.admin_access?
      # Admin access is king: OK

    elsif not current_user.user_type.create_group_incidents?
      # Can not create
      errors.add_to_base "You are not authorized to add incidents to any group"

    elsif not current_user.groups.map{|g| g.id}.include? group_id
      errors.add_to_base %(You are not authorized to add incidents to the group "#{group.name}" (since you are not a member of it))

    else
      true
    end
  end

  def create_histories
    # Create incident log for the creator
    handled_by = incident.inherit_column :handled_by
    unless handled_by.history.find_by_incident_id incident.id
      handled_by.history.create! :incident => incident
    end

    users = {}
    users[handled_by.id] = true

    groups = {}
    buffer = [group].compact

    # create incident logs for all recursively affected users.
    History.transaction do
      while group = buffer.shift
        groups[group.id] && next or groups[group.id] = true

        buffer.concat group.group_members.compact

        group.users.each do |user|
          users[user.id] && next or users[user.id] = true
          next if user.history.find_by_incident_id(incident.id)

          user.history.create! :incident => incident
        end

      end
    end
  end

end