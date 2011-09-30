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

class DeliveryType < ActiveRecord::Base
  validates_uniqueness_of :code

  validate :group_field_exists

  def to_param
    self.code
  end

  def to_label
    self.to_param
  end

  private

  def group_field_exists
    unless (columns = Group.columns.map(&:name)).include? group_recipient_field.to_s
      errors.add(
        :group_recipient_field,
        "must be an existing column in the groups table (%s)" % columns.sort.join(", ")
      )
    end
  end

end