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

require 'yaml'
require 'ostruct'

path = File.join File.expand_path(File.dirname __FILE__), "../config/version.yml"
data = YAML.load IO.read(path)
version = OpenStruct.new(data)

def version.to_s
  string = [[major,minor,tiny].compact.join("."), patch].compact.join("-")

  # YAML will automatically convert dates to Date objects.
  date ? "%s (%s)" % [string, date.strftime] : string
end

APP_VERSION = version.freeze