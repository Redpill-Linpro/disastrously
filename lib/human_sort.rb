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

# Include in Array e.g. in environment.rb, like so:
# Array.send :include, HumanSort
module HumanSort

  # Shamelessly stolen (well, before it was modified) from
  # http://blog.labnotes.org/2007/12/13/rounded-corners-173-beautiful-code/
  #
  # Will correctly sort strings with integers in it,
  # so e.g. %w(a1 a12 a2) becomes ["a1", "a2", "a12"].
  def human_sort(&block)
    if block_given?
      sort_by { |key| block.call(key).to_s.split(/(\d+)/).map { |v| v =~ /\d/ ? v.to_i : v.downcase } }
    else
      sort_by { |key| key.to_s.split(/(\d+)/).map { |v| v =~ /\d/ ? v.to_i : v.downcase } }
    end
  end

end