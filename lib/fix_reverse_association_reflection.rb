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
# Fix active scaffold code that monkey patches active record reflection in
# order to handle parent/children self referencing associations ...
#
module ActiveRecord
  module Reflection
    class AssociationReflection

      def reverse
        if @reverse.nil? and not self.options[:polymorphic]
          reverse_matches = reverse_matches_for(self.class_name.constantize) rescue []

          # If a model is referencing itself in a parent/children (one to many)
          # relationship, this reflection might end up in the list of matches
          # against itself.
          reverse_matches.reject! {|m| m == self }

          # grab first association, or make a wild guess
          @reverse = reverse_matches.blank? ? false : reverse_matches.first.name
        end
        @reverse
      end

    end
  end
end