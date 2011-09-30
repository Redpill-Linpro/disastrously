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

# Remove annoying deprecation warning about deprecated translation syntax
# (shows up when running tests).
#
# To use, put this in config/environment.rb:
#   Object.send :include, FixAs
module FixAs

  def self.included(base)
    base.class_eval do

      def as_(key, options = {})
        text = I18n.translate("%{#{key}}", {
          :scope => [:active_scaffold],
          :default => key.is_a?(String) ? key : key.to_s.titleize
        }.merge(options)) unless key.blank?

        text || key 
      end

    end
  end

end