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

# Only include code from this project in a backtrace (exclude Rails framework,
# gems etc. since in maybe 95% of the time the bug comes from our code, not
# auxiliary code).
class Exception
  alias :old_backtrace :backtrace

  def backtrace
    if bt = old_backtrace
      bt.select {|l| l =~ /^#{Rails.root.to_s}/}
    end
  end
end