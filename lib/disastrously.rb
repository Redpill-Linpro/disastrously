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

# Disastrously

# Require dependencies first:
require 'exception_notification'
require 'fastercsv'

# Normal boot code:
require 'pathname'

plugin_root = File.join File.dirname(__FILE__), ".."

%w(controllers helpers models).each do |dir|
  path = File.join(plugin_root, "lib/#{dir}/")
  $LOAD_PATH << path
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end

puts "Disastrously #{APP_VERSION}"

# Patches:

# Add add_foreign_key and remove_foreign_key methods to migrations/schema.rb:
ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:include, DBHelper)

# Automatically assign created_by/updated_by when available
ActiveRecord::Base.send :include, AutoAssignUsers

# Add to_full_csv method to arrays (only useful if they contain model objects
# of the same type):
Array.send :include, FullCsv::To

# Add parse_full_csv method to string (generates an array of array attributes):
String.send :include, FullCsv::Parse

# Remove annoying deprecation warning about deprecated translation syntax
# (shows up when running tests). (Originally I placed this in
# spec/spec_helper.rb, but I don't think it's wise to let the test environment
# differ more than necessary from dev/stage/prod.)
Object.send :include, FixAs

# Don't include code from gems in backtrace:
require 'clean_backtrace'

# Add human_sort method to arrays.
Array.send :include, HumanSort

# Add word_wrap method to strings.
String.send :include, WordWrap

# Fix active scaffold code that monkey patches active record reflection in
# order to handle parent/children self referencing associations ...
require 'fix_reverse_association_reflection'