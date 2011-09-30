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

# Automatically assign created_by/updated_by when available.
#
# To use, add in config/environment.rb:
# ActiveRecord::Base.send :include, AutoAssignUsers
module AutoAssignUsers

  def self.included(base)
    base.class_eval do
      before_create do |record|
        if record.attribute_names.include? "created_by_id"
          record.created_by = current_user
          raise "ERROR: AutoAssignUsers: current_user is nil!" unless current_user
        end
        if record.attribute_names.include? "updated_by_id"
          record.updated_by = current_user
          raise "ERROR: AutoAssignUsers: current_user is nil!" unless current_user
        end
      end

      before_update do |record|
        if record.attribute_names.include? "updated_by_id"
          record.updated_by = current_user
          raise "ERROR: AutoAssignUsers: current_user is nil!" unless current_user
        end
      end
    end
  end

end