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

module Disastrously
  class Sync

    autoload :FromLDAP, 'disastrously/sync/from_ldap'

    include Rake::DSL

    CONFIG_FILE = %(config/sync.yml)

    def initialize(config)
      @config = config
      @stats = {}
    end

    def run!
      # There's multiple foreign keys and other constraints that we're going to
      # temporarily break, so the transaction is not just best practice: We have
      # to have it.
      ActiveRecord::Base.transaction do
        @config[:perform_actions].each do |action|
          send action
        end
      end
    end

    private

    # Show statistics for performed actions.
    def show_stats
      puts "Stats:"
      puts @stats.map { |model, actions|
        "  #{model}:\n" + actions.map { |action, stats|
          "    #{action}: #{stats}"
        }.join("\n")
      }
    end

    def cancel
      raise %(Canceling to avoid transaction commit ...)
    end

    # Increment stats for given model and action.
    def incr(model, action, int=1)
      @stats[model] ||= {}
      @stats[model][action] ||= 0

      @stats[model][action] += int
    end

    def inspect(data)
      $VERBOSE ? data.inspect : ""
    end

  end
end