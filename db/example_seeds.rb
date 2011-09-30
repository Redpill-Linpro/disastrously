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
# This file adds example data (severities, delivery types and lots of groups).
#
# Activate with 'bundle exec rake disastrously:seed:example'.
#

#letters = %w(Alpha Beta Chi Delta Eta Gamma Iota Kappa Lambda Mu Nu Omega Omicron Phi Pi Psi Rho Sigma Tau Theta Upsilon Xi Zeta)
letters = %w(Alpha Beta Chi)
tech = %w(base bit buzz code data digi giga info link module object state system tag tele trade venture verti)

groups = Group.all.size
severities = Severity.all.size
delivery_types = DeliveryType.all.size
memberships = GroupMembership.all.size

ActiveRecord::Base.transaction do
  letters.each do |letter|
    proxy = Group.create(:name => "All #{letter}")

    tech.map {|t| "%s%s" % [letter, t] }.each do |group_name|
      group = Group.create(:name => group_name)
      next if group.new_record?
      group.member_of_memberships.create :parent => proxy
    end
  end

  ["0. No Impact", "1. Low Impact", "2. Medium Impact", "3. Severe", "4. Critical"].each do |severity|
    Severity.create :title => severity
  end

  DeliveryType.create :code => "email", :description => "Notify via email", :group_recipient_field => :notification_mail
  DeliveryType.create :code => "sms",   :description => "Notify via SMS",   :group_recipient_field => :notification_phone
end

puts "Created %d severities." % (Severity.all.size - severities)
puts "Created %d delivery types." % (DeliveryType.all.size - delivery_types)
puts "Created %d groups." % (Group.all.size - groups)
puts "Created %d group memberships." % (GroupMembership.all.size - memberships)