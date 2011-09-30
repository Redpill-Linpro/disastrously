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
# This controller acts as the ApplicationController for Disastrously.
#
class DisastrouslyController < ApplicationController
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout 'standard'

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :passwd

  # Generate exception notifications on staging/production:
  include ExceptionNotification::Notifiable

  # Don't show a blank new record for associated columns by default.
  ActiveScaffold::DataStructures::Column.show_blank_record = false

  before_filter :generate_menu

  protected

  USE_HTTP_AUTH = true

  # current_user returns the currently logged in user or nil if the
  # current user is not authenticated
  def current_user
    User.find_by_id session[:user_id]
  end

  # Also available to views.
  helper_method :current_user

  def authenticate
    if USE_HTTP_AUTH
      authenticate_or_request_with_http_basic do |username, password|
        if user = User.find_by_username(username)
          session[:user_id] = user.id
        end
      end
    end

    current_user
  end

  def generate_menu
    @menu = @admin_menu = []

    if user = current_user
      @menu = user.groups.human_sort { |g| g.name }.map { |g| [g.name, list_groups_incidents_url(g)] }

      if user.user_type.admin_access?
        @admin_menu = [
          "admin/incidents",
          nil,
          "admin/users",
          "admin/groups",
          nil,
          "admin/user_types",
          "admin/severities",
          nil,
          "admin/deliveries",
          "admin/delivery_types",
        ];
      end
    end
  end

end