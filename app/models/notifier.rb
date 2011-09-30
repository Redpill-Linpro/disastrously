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

class Notifier < ActionMailer::Base

  def error_report(incident, group, delivery)
    configuration = YAML::load(File.open(Rails.root.join "config/notification.yml"))
    settings = configuration[Rails.env] || {}

    subject     "Failed to deliver incident to #{group.name}"
    from        settings[:from]
    recipients  settings[:default_reply_to] || settings[:bcc] || settings[:cc]

    body        :incident => incident, :group => group, :delivery => delivery
  end

  # Send a mail with the contents of :body.
  def raw(conf)
    config = conf.dup
    @body = config.delete :body

    config.each_pair do |field, data|
      send field, data
    end
  end

end