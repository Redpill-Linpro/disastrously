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

module Admin::UsersHelper

  def user_user_memberships_column(record)
    # we manually save the group memberships in after_create/update_save
    # since active scaffold doesn't support this (has-many-through association).
    # because of this, we need to reload the record here to update the data.
    record.reload
    record.user_memberships.map { |gm| gm.group.name }.join(", ")
  end

  def user_password_form_column(record, options)
    # don't show the password, since it's meaningless when it's encrypted in
    # the database
    password_field_tag options, "", :class => "password-input text-input"
  end

  # The only reason we need this is because active scaffold won't correctly add
  # the checked boxes back to the form if validation fails.
  def user_groups_form_column(record, options)
    groups = record.group_checkboxes.map {|k,v| v.values.first} if record.group_checkboxes
    groups ||= record.groups.map {|g| g.id}

    # The string "skøyen" and "skøyen" might look the same, but if they don't
    # share the same encoding comparing them will return false. Incoming data
    # in Rails 2.3.x defaults to ASCII-8BIT, thus breaking such comparisons. We
    # force the parameter data to be UTF-8, and everything should be dandy
    # again.
    groups.map! {|id| id.force_encoding "UTF-8"} if RUBY_VERSION.to_i >= 1.9

    out = %(<ul id="record_groups" class="checkbox-list groups">)
    Group.all.human_sort {|g| g.name }.each_with_index do |group, index|
      out << %(<li>)
      out << check_box_tag("record[groups][#{index}][id]", group.id, groups.include?(group.id))
      out << label_tag("groups", group.name)

      out << %(</li>)
    end

    out << %(</ul>)
    out << select_links("groups")
  end
end