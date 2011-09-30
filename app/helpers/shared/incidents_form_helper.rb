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

module Shared::IncidentsFormHelper

  # Columns (view):

  include Shared::RecipientFields

  def incident_timestamps_show_column(record)
    timestamps = record.inherit_column(:timestamps).sort_by(&:datetime)
    prev = nil

    timestamps.map do |ts|
      remarks = IncidentTimestamp.compare(prev, ts)

      text = ts.datetime.to_s
      text += " (#{remarks}) " if remarks
      text += "- %s" % ts.comment if ts.comment.to_s.any?

      prev = ts
      text
    end.join "<br/>"
  end

  def incident_complete_description_column(record)
    clean_column_value(record.inherit_column :description).gsub("\n", "<br/>")
  end

  # The incident text is expected to be in the following format:
  #
  # Description:
  # (...)
  # Consequences:
  # (...)
  # Response:
  # (...)
  #
  # We only want the description part in the list view.
  def incident_list_description_column(record)
    description = clean_column_value(record.inherit_column :description)

    if description =~ /consequences:|konsekvenser:/i
      $`.sub(/beskrivelse:|description:/i, "").strip.gsub("\n", "<br/>")

    else
      if (description = description.strip).size > 262
        description = description[0..256] + " (...)"
      end

      description.gsub("\n", "<br/>")
    end
  end

  def incident_parent_column(record)
    "[%s] %s" % [record.parent.id, record.parent.title] if record.parent
  end

  def incident_groups_column(record)
    groups = record.groups.map(&:name)
    sub_groups = record.children.map {|i| [i.groups, i.children.map(&:groups)]}.flatten.map {|g| g.name}.flatten.uniq
    sub_groups -= groups

    out = groups.join(", ")
    out += " (+ %s)" % sub_groups.join(", ") if sub_groups.any?
    out
  end

  def incident_started_at_column(record)
    # Even if we didn't use inherit_column, we need to do this to trigger the
    # correct time format:
    record.inherit_column(:started_at)
  end

  def incident_ended_at_column(record)
    record.inherit_column(:ended_at)
  end

  def incident_created_at_column(record)
    record.inherit_column(:created_at)
  end

  def incident_updated_at_column(record)
    record.inherit_column(:updated_at)
  end

  def incident_sla_time_column(record)
    if record.parent and record.timestamps.empty?
      time = record.parent.sla_time
    else
      time = record.sla_time
    end

    if time > 0
      distance_of_time_in_words time
    else
      "-"
    end
  end

  def incident_service_window_time_column(record)
    if record.parent and record.timestamps.empty?
      time = record.parent.service_window_time
    else
      time = record.service_window_time
    end

    if time > 0
      distance_of_time_in_words time
    else
      "-"
    end
  end

  # Form columns (edit):

  def incident_delivery_child_notice_form_column(record, options)
    %(
      <b>Note:</b> If you do not specify any <b>delivery methods</b> above, the
      delivery method (and <i>deliver to whom</i>-setting) from the <b>parent
      incident</b> will be used for the groups that are associated with <b>both
      this incident and the parent</b>.
    )
  end

  def incident_parent_form_column(record, options)
    incident_parent_column(record) || "(None)"
  end

  def incident_delivery_types_form_column(record, options)
    return %(No #{link_to "delivery types", :controller => "admin/delivery_types"} exist!) if DeliveryType.all.size == 0

    DeliveryType.all.map do |delivery_type|
      delivery_types = record.delivery_types || []
      checked = delivery_types.include?(delivery_type.code)

      check_box_tag("%s[]" % options[:name], delivery_type.code.gsub(" ", "_").gsub("\"", "'"), checked) +
        %{<label>#{delivery_type.description}</label><br/>}
    end.join("\n")
  end

  def incident_deliver_to_whom_form_column(record, options)
    selected = Incident::DELIVER_TO_WHOM_DEFAULT

    Incident::DELIVER_TO_WHOM.map do |value, label|
      radio_button_tag(options[:name], value, value == selected) + label
    end.join("<br/>") + "<br/>"
  end

  def incident_handled_by_form_column(record, options)
    users = User.all

    opts = users.human_sort {|u| u.username }.map do |user|
      if record.handled_by and record.handled_by == user
        selected = %(selected="selected")

      elsif not record.handled_by and current_user == user
        selected = %(selected="selected")

      else
        selected = ""
      end
      %(<option value="%s" %s>%s</option>) % [user.id, selected, user.username]
    end

    root = options[:name].sub(/\[handled_by\]$/, "")
    select(root, :handled_by, opts.join("\n"), {}, options)
  end

  def incident_separator_form_column(record, options)
    "<hr/>"
  end

  def incident_separator_start_form_column(record, options)
    "<br/>"
  end

  def incident_empty_form_column(record, options)
    "<br/>"
  end

  def incident_affects_columns_form_column(record, options)
    javascript = %(
      element = $(this.parentNode.parentNode.parentNode.parentNode).select('*[class|=%s]')[0];
      root = element.parentNode.parentNode;

      // We might have en extra div element as a parent if this field contains
      // errors (Rails marks it that way).
      if (root.tagName == 'DL') {
        root.toggle();
      } else {
        root.parentNode.toggle();
      }
    )

    Incident::OVERRIDEABLE.map do |column|
      selected = affects_column?(record, column, options[:name])
      tag = check_box_tag(options[:name] + "[]", column, selected, :onclick => javascript % column)
      tag + %{<label>#{column.humanize}</label>}
    end.join
  end

  private

  # Returns whether the given column checkbox/form field should be
  # checked/visible or not.
  def affects_column?(record, column, name)
    if record.new_record?
      not (record.parent or name =~ /children/)

    else
      not record.send(column).nil?
    end
  end

end