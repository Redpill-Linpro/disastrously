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

class IncidentTimestamp < ActiveRecord::Base
  belongs_to :incident

  validates_presence_of :incident, :datetime

  before_validation :set_booleans

  # Supply two incident timestamps and get sla/service window changes as human
  # readable text in return.
  def self.compare(a, b)
    text = []
    if (a and a.sla?) and not (b and b.sla?)
      text << "SLA ends"

    elsif (b and b.sla?) and not (a and a.sla?)
      text << "SLA begins"
    end

    if (a and a.service_window?) and not (b and b.service_window?)
      text << "Service window ends"

    elsif (b and b.service_window?) and not (a and a.service_window?)
      text << "Service window begins"
    end

    text.any? ? text.join(", ") : nil
  end

  private

  def set_booleans
    # The database will automatically convert nil/NULL to false, but in order
    # to not rely on the database we add this small "fixer" here:
    self.sla = false unless sla
    self.service_window = false unless service_window

    true
  end
end