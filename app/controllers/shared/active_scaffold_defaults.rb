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

module Shared::ActiveScaffoldDefaults

  private

  # Hmm, for some reason, the instance methods defined here are completely
  # ignored by active scaffold.
  #
  # So I actually have to copy them to each controller :-(

  def conditions_for_collection
    ['incidents.parent_id IS NULL']
  end

  # these are used by active scaffold to control access:
  def create_authorized?
    current_user.user_type.admin_access? or current_user.user_type.create_group_incidents?
  end

  def update_authorized?
    true
  end

  def self.included(base)
    base.instance_eval do

      extend ClassMethods

      # Include the timestamps helper methods (since we're rendering it as a subform).
      helper :incident_timestamps
    end
  end

  module ClassMethods

    private

    # Call inside active_scaffold block with config and all the actions that
    # should be configured. Available actions are: %w{list show create update search subform}
    def default(config, *actions)

      config.columns << :list_description
      config.columns << :delivery_types
      config.columns << :recipient_fields
      config.columns << :handled_by
      config.columns << :separator
      config.columns << :separator_start
      config.columns << :deliver_to_whom
      config.columns << :delivery_child_notice
      config.columns << :affects_columns

      config.columns << :started_at
      config.columns << :ended_at

      create_update_columns = %w(
        groups
        deliver_to_whom
        delivery_types
        recipient_fields
        affects_columns
        separator
        title
        handled_by
        timestamps
        unknown_start
        ongoing
        description
        severity
        children
      )

      config.actions = actions
      config.actions.each do |action|
        case action
        when :list
          config.list.columns = %w{
            id
            title
            groups
            handled_by
            severity
            list_description
            started_at
            ended_at
            sla_time
            service_window_time
          }

          config.list.per_page = 50
          config.list.sorting = [ { :ended_at => :desc }, { :started_at => :desc }, { :created_at => :desc }, { :id => :asc } ]

        when :show
          config.show.columns = %w{
            id
            title
            groups
            handled_by
            timestamps
            complete_description
            severity
            sla_time
            service_window_time
            created_by
            created_at
            updated_by
            updated_at
          }

          # It's useful to get the show-url in the browser address bar, so turn
          # off ajax for those.
          config.show.link.inline = false

        when :create
          config.create.columns = create_update_columns - %w(deliver_to_whom)

        when :update
          config.update.columns = create_update_columns

        when :search

        when :subform
          config.subform.layout = :vertical
          config.subform.columns = %w(
            separator_start
            groups
            deliver_to_whom
            delivery_types
            delivery_child_notice
            recipient_fields
            affects_columns
            separator
            title
            handled_by
            unknown_start
            ongoing
            description
            severity
          )

        else
          raise "Unknown action '#{action}'"
        end
      end

      config.columns[:parent].clear_link
      config.columns[:severity].clear_link

      # Default is subform, which is what we want.
      #config.columns[:timestamps].form_ui = :subform
      config.columns[:timestamps].allow_add_existing = false  # active scaffold v2.4 (aka. edge / master-branch)
      config.columns[:children].allow_add_existing = false    # active scaffold v2.4 (aka. edge / master-branch)

      config.columns[:handled_by].form_ui     = :select
      config.columns[:severity].form_ui       = :select

      config.columns[:ongoing].form_ui        = :checkbox
      config.columns[:unknown_start].form_ui  = :checkbox

      config.columns[:groups].form_ui         = :select
      config.columns[:groups].label           = "Affects groups"
      config.columns[:groups].clear_link

      config.columns[:started_at].label       = "Start time"
      config.columns[:ended_at].label         = "End time"

      config.columns[:delivery_types].label   = "Delivery method"

      config.columns[:ongoing].label          = "Incident still ongoing"
      config.columns[:separator].label        = ""
      config.columns[:separator_start].label  = ""

      config.columns[:children].label         = "Children (ie. overrides)"
      config.columns[:list_description].label = "Description"

      config.columns[:delivery_child_notice].label = ""
    end
  end

end