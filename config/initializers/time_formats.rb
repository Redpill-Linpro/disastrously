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

# Set better date/time format
Date::DATE_FORMATS[:short]    = '%Y-%m-%d'
Date::DATE_FORMATS[:long]     = '%Y-%m-%d'
Date::DATE_FORMATS[:default]  = '%Y-%m-%d'

Time::DATE_FORMATS[:short]    = '%H:%M'
Time::DATE_FORMATS[:default]  = '%Y-%m-%d - %H:%M'
Time::DATE_FORMATS[:long]     = '%Y-%m-%d - %H:%M'

DateTime::DATE_FORMATS[:default] = '%Y-%m-%d - %H:%M'