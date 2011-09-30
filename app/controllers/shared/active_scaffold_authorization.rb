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

# Module needed by active scaffold controllers dealing with incidents in order
# to handle access control/authorization.
#
# The admin module allows everything for anyone who already has access (is
# admin), so it shouldn't need this module.
module Shared::ActiveScaffoldAuthorization
  def self.included(base)
    base.class_eval do
      before_filter :authorize_action
      
      private

      # Even though active scaffold has its own checks,
      # we 1) don't trust it, 2) want to render a
      # pretty access denied partial.
      def authorize_action
        # since these are regexps, we'll catch the most dangerous actions first:
        use_layout = (not request.xhr?)

        if params[:action] =~ /(delete|destroy)/
          # don't allow this.
          # do it manually in the database if it has to be done.
          render :partial => "shared/access_denied", :layout => use_layout

        elsif params[:action] =~ /(edit|update)/
          # update existing
          if current_user.user_type.admin_access?
            # OK

          elsif not incident = Incident.find_by_id(params[:id])
            # No incident: doesn't matter

          elsif current_user.user_type.create_group_incidents? and [incident.created_by, incident.handled_by].include? current_user
            # OK

          else
            render :partial => "shared/access_denied", :layout => use_layout
          end

        elsif params[:action] =~ /(add|create|new)/
          # add new
          unless current_user.user_type.admin_access? or current_user.user_type.create_group_incidents?
            render :partial => "shared/access_denied", :layout => use_layout
          end

        elsif params[:action] =~ /(show|nested|render|row)/
          # view existing
          if current_user.user_type.admin_access?
            # OK

          elsif History.find_by_user_id_and_incident_id(current_user.id, params[:id])
            # OK

          elsif not incident = Incident.find_by_id(params[:id])
            # No incident: Doesn't matter

          elsif incident.handled_by == current_user or current_user.groups.include? incident.group
            # OK

          else
            render :partial => "shared/access_denied", :layout => use_layout
          end

        elsif params[:action] =~ /(index|list)/
          # these are overridden and used to redirect: OK

        else
          # catch all:
          # we don't know what kind of action this is,
          # but we'd like to control what passes through.
          render :partial => "shared/access_denied", :layout => use_layout
        end
      end

    end
  end
end