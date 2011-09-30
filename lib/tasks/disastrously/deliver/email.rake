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

# Print stack trace to logger/stdout when rescuing exception from given block.
def verbosely(error_msg, continue=false)
  yield if block_given?

rescue Exception => e
  $stderr.puts error_msg
  msg = %(%s\n%s: %s\n%s) % [error_msg, e.class.name, e.message, e.backtrace.join("\n")]
  Rails.logger.error msg
  abort unless continue
end

namespace :disastrously do
  namespace :deliver do

    desc 'Deliver any mail presently queued in the deliveries table.'
    task :email => :environment do

      # Stub current_user ...
      ActiveRecordPermissions::ModelUserAccess::Model::ClassMethods.class_eval do
        def current_user
          User.find_by_username("admin")
        end
      end

      email_type = DeliveryType.find_by_code!("email")
      Delivery.find_each(:conditions => { :delivered_at => nil, :delivery_type_id => email_type.id }) do |delivery|
        puts %(%s: Sending mail to %s ...) % [delivery.id, delivery.recipient]

        # Hmm, it would be nice to deliver all mail that's possible, but we
        # risk sending mails multiple times in case of errors.
        verbosely(%(ERROR: Delivery: Failed to update delivered_at for %s!) % delivery.inspect) do
          delivery.deliver!
        end
      end
    end

  end
end