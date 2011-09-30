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

class Admin::SeveritiesController < Admin::BaseController
  active_scaffold :severity do |config|
    config.actions.exclude :nested

    config.show.columns = %w{title complete_description updated_at created_at}
    config.list.columns = %w{title description}
    config.create.columns = %w{title description}
    config.update.columns = %w{title description}

    config.list.sorting = { :title => :asc }
  end

end