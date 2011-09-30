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
# Validation code for Incident module.
#
# With the introduction of parent/child relationship between incidents (where
# an incident can have a parent from which it inherits data) the validation
# code becomes slightly more complex than simply using the built in Rails
# standard validators.
#
module Incident::ValidationCode

  def self.included(base)
    base.class_eval do

      validate :title_present
      validate :description_present
      validate :handled_by_present
      validate :severity_present

    end
  end

  private

  def title_present
    errors.add :title,        :empty unless parent or title.to_s.any?
  end

  def description_present
    errors.add :description,  :empty unless parent or description.to_s.any?
  end

  def handled_by_present
    errors.add :handled_by,   :empty unless parent or handled_by
  end

  def severity_present
    errors.add :severity,     :empty unless parent or severity
  end

end