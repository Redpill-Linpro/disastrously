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

class Delivery < ActiveRecord::Base
  belongs_to :incident
  belongs_to :delivery_type
  belongs_to :created_by, :class_name => "User", :foreign_key => :created_by_id
  belongs_to :updated_by, :class_name => "User", :foreign_key => :updated_by_id

  validates_presence_of :created_by, :updated_by
  validates_presence_of :incident, :delivery_type, :recipient, :message

  # Actually deliver this delivery instance. Raises exception upon failure.
  def deliver!
    config = YAML.load(IO.read Rails.root.join("config/notifier.yml"))[Rails.env] || {}

    case delivery_type.code
    when "email"
      config = config[:email] || {}

      # TODO: Heh, replace recipient column with group_id column please ...
      group = incident.groups.find_by_notification_mail(recipient)
      raise %(Can't find group corresponding to the current delivery: %s) % self.inspect unless group

      reply_to = group.reply_to
      reply_to = config[:reply_to] unless reply_to.to_s.chars.any?

      Notifier.deliver_raw(
        config.merge(
          :recipients => recipient,
          :from       => reply_to,
          :subject    => incident.title,
          :body       => message
        )
      )

    else
      raise %(Process code for this delivery type (%s) has not been implemented yet...) % delivery_type.code
    end

    self.delivered_at = Time.now
    save!
  end
end