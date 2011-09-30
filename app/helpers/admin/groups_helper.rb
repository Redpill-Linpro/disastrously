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

module Admin::GroupsHelper

  def group_complete_description_column(record)
    clean_column_value(record.description).gsub("\n", "<br/>")
  end

  def group_user_memberships_column(record)
    # we manually save the group memberships in after_create/update_save
    # since active scaffold doesn't support this (has-many-through association).
    # because of this, we need to reload the record here to update the data.
    record.reload
    record.user_memberships.map { |gm| gm.user.username }.join(", ")
  end

  def group_member_of_memberships_column(record)
    record.reload
    record.member_of_memberships.map { |gm| gm.parent.name }.join(", ")
  end

  def group_group_member_memberships_column(record)
    record.reload
    record.group_member_memberships.map { |gm| gm.group.name }.join(", ")
  end

end