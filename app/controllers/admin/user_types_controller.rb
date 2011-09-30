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

class Admin::UserTypesController < Admin::BaseController
  active_scaffold :user_type do |config|

    config.show.columns = %w{name complete_description read_group_incidents create_group_incidents admin_access updated_at created_at}
    config.list.columns = %w{name description read_group_incidents create_group_incidents admin_access}

    config.create.columns = %w{name description read_group_incidents create_group_incidents admin_access}
    config.update.columns = %w{name description read_group_incidents create_group_incidents admin_access}

    %w{read_group_incidents create_group_incidents admin_access}.each do |column|
      config.columns[column].form_ui = :checkbox
    end

    config.list.sorting = { :name => :asc }
  end

end