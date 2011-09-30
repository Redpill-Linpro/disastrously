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

# See https://github.com/smartinez87/exception_notification/tree/2-3-stable
ExceptionNotification::Notifier.sender_address  = %("Disastrously Exception Notifier" <disastrously@example.com>)
ExceptionNotification::Notifier.email_prefix    = "[Disastrously #{Rails.env}] "

# Where to send an exception email if an exception occurs. If you are the
# current maintainer / hacker on this project, you will want to add your
# email to this list.
recipients = %w(developer@example.com)

if Rails.env.production?
  # Only add bugtracker when in production. No need to spam it with stuff from
  # staging.
  recipients += %w(bugtracker@example.com)
end

# Note: Configuring exception notification recipients via
# config/environments/{staging,production}.rb doesn't work since it's evaluated
# inside the Rails class.
#ExceptionNotification::Notifier.exception_recipients = recipients
