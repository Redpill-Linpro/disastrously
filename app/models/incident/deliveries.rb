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

module Incident::Deliveries

  def self.included(base)
    base.class_eval do
      after_save :create_deliveries
    end
  end

  protected

  # Return the child incident (furthest away) which is associated with the
  # given group.
  def find_incident(group)
    children.each do |c|
      if incident = c.find_incident(group)
        return incident
      end
    end

    # Might be nil.
    return children.detect {|c| c.groups.include? group }
  end

  private

  def create_deliveries
    return if delivery_types.nil? or delivery_types.empty?

    case deliver_to_whom
    when "only_new"
      if @new_groups
        new_groups = @new_groups.map { |g| [g, g.all_group_members] }.flatten.uniq
        create_deliveries_for new_groups
      end

    else
      # == "all" (or unknown option)
      all_groups = groups.map { |g| [g, g.all_group_members] }.flatten.uniq
      create_deliveries_for all_groups
    end
  end

  # Deliver incidient reports for all recursively affected groups.
  def create_deliveries_for(groups)
    # If a child/sub incident has chosen one or more delivery types then don't
    # create deliveries for those groups (or else they'll be created twice).
    children.each do |child|
      groups -= child.groups if (child.delivery_types || []).any?
    end

    groups.each do |group|
      delivery_types.each do |delivery_type_code|
        delivery_type = DeliveryType.find_by_code(delivery_type_code)
        recipient_field = delivery_type.group_recipient_field

        if not (recipient = group.send(recipient_field).to_s).chars.any?
          logger.info "SKIPPED: %s / %s: Could not create delivery because %s was empty." %
            [group.name, delivery_type.code, recipient_field]
          next
        end

        delivery = deliveries.create(
          :delivery_type_id => delivery_type.id,
          :recipient => recipient,
          :message => create_delivery_message(group),

          :created_by => created_by,
          :updated_by => updated_by
        )

        if delivery.valid?
          logger.info "success: %s / %s: Created delivery to %s." % [group.name, delivery_type.code, recipient]
        else
          logger.error "ERROR: %s / %s: Failed to create delivery to %s." % [group.name, delivery_type.code, recipient]

          logger.error delivery.errors.inspect
          Notifier.deliver_error_report(self, group, delivery)
        end
      end
    end
  end

  def create_delivery_message(group)
    # If the group is associated with one of the children incidents, we need to
    # use the child incident as context when creating the message in order to
    # get the information in the message right.
    incident = find_incident(group) || self

    # Instead of Rails::Configuration.new.view_path:
    plugin_views = File.join(File.dirname(File.expand_path(__FILE__)), "../../views")

    # This should be done in the controller (obviously), but since active
    # scaffold completely owns the controller ...
    ActionView::Base.new(plugin_views).render(
      :partial => 'admin/deliveries/message', :locals => {:incident => incident, :group => group}
    )
  end

end