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
# This file is run with rake db:seed or db:setup.
#
# It adds a usertype "Admin" which provides admin rights, and adds a user
# "admin" with password "admin" of that usertype.
#
if UserType.find_by_name("Admin") and User.find_by_username("admin")
  puts %(UserType Admin and User Admin already exist.)

else
  usertype, user, password = nil, nil, nil

  ActiveRecord::Base.transaction do
    usertype = UserType.create!({
      :name => "Admin",
      :description => "The administrators have full access to the system",
      :read_group_incidents => true,
      :create_group_incidents => true,
      :admin_access => true
    }) unless UserType.find_by_name("Admin")

    puts "Created usertype '%s'." % usertype.name if usertype

    user = User.create!({
      :username => "admin",
      :user_type => UserType.find_by_name("Admin"),
      :password => (password = "admin")
    }) unless User.find_by_username("admin")
  end

  puts "Created user '%s' with password '%s'." % [user.username, password] if user

end