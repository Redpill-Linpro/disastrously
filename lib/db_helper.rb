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

# Add extra functions to migrations/schema.rb.
# To use, add this to e.g. config/environment.rb:
# ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:include, DBHelper)
#
# The methods below will be echoed to console during migration runs when they
# are executed.
module DBHelper

  # Multiple options are available as a trailing hash.
  # add_foreign_key :user, :group
  # add_foreign_key :group, :group, :parent_id
  # add_foreign_key :group, :group, :parent_id, :deferrable => true, :cascade_delete => false
  # add_foreign_key :user, :group, :deferrable => true, :cascade_delete => false
  def add_foreign_key(from, to, keyname=nil, options=nil)
    options, keyname = keyname, options if keyname and keyname.is_a? Hash and options.nil?

    keyname ||= "#{to}_id"
    options ||= {}

    sql = %{ALTER TABLE #{from}s ADD FOREIGN KEY (#{keyname}) REFERENCES #{to}s}
    sql << %{ ON DELETE CASCADE} if options.delete :cascade_delete
    sql << %{ DEFERRABLE INITIALLY DEFERRED} if options.delete :deferrable

    abort "ERROR: Unknown options: #{options.keys.join ", "}." if options.keys.any?
    execute sql
  end

  def remove_foreign_key(from, to)
    execute %{ALTER TABLE #{from}s DROP CONSTRAINT #{from}s_#{to}_id_fkey;}
  end

end