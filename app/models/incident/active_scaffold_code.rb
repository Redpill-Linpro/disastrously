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
# Active Scaffold related code for Incident model.
#
# We don't have to have this in its own module, we simply place it here to
# reduce the clutter in the main Incident file.
#
module Incident::ActiveScaffoldCode

  def self.included(base)
    base.class_eval do

      # Since we need to hard code the logic associated with the different choices,
      # we might as well skip the table creation and hard code the choices as well:
      const_set("DELIVER_TO_WHOM", {
        :all => "To all selected",
        :only_new => "Only to new (ie. non-bold) groups",
      })

      const_set("DELIVER_TO_WHOM_DEFAULT", :only_new)

      # Overrideable columns can be added to child incidents (incidents with a
      # parent) thus overridding the value of the same column in the parent
      # (for the groups the child incident affects).
      const_set("OVERRIDEABLE", %w(title handled_by unknown_start ongoing description severity))

      # This is used by the controller to tell the incident what kind of
      # deliveries it should create. Optimally this logic would be in the
      # controller, but since we're using active scaffold things are not always
      # that easy ...
      attr_accessor :delivery_types
      attr_accessor :group_checkboxes
      attr_accessor :deliver_to_whom
      attr_accessor :affects_columns

      before_validation :update_affected_columns

      validate :authorization
    end
  end

  # This is not the safety check, the safety check is the authorization
  # validation. This is just something that active scaffold hits to decide
  # wheter or not to render the update link.
  def authorized_for_update?
    if not current_user
      false

    elsif current_user.user_type.admin_access?
      true

    elsif current_user.user_type.create_group_incidents? and [self.created_by_id.to_s, self.handled_by_id.to_s].include? current_user.id.to_s
      true

    else
      false
    end
  end

  private

  def authorization
    if not current_user
      # This happens outside a normal requst/response cycle.
      false

    elsif current_user.user_type.admin_access?
      # Admin access is king: OK

    elsif not current_user.user_type.create_group_incidents?
      # Can not create
      errors.add_to_base "You are not authorized to create any incidents"
    end
  end

  # self.affects_columns must include each column in Incident::OVERRIDEABLE to
  # prevent those to become nil. This needed in order for child incidents
  # ("overrides") to work properly, and the same code is used for parent
  # incidents.
  #
  # This might cause confusion when using e.g. the console: If you run "valid?"
  # on a valid incident without setting affects_columns first, lots of columns
  # will be erased which obviously will cause it to become invalid instead.
  #
  # Should this be implemented differently? Perhaps ...
  def update_affected_columns
    Incident::OVERRIDEABLE.each do |column|
      self.send "#{column}=", nil unless (affects_columns||[]).include? column.to_s
    end
  end

end