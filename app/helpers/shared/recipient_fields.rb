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

# For use by Incidents controllers.
# Whenever the user changes group via the select box, an ajax request is shot
# off to update the delivery table.
module Shared::RecipientFields
  
  def incident_groups_form_column(record, options)
    # We need :with => "group=..." in order for the value to be evaluated in javascript.
    onchange = remote_function(
      :update => options[:id].sub(/_groups_/, "_recipient_fields_"),
      :method => :post,
      :url => { :controller => "/export", :action => "recipient_fields"},
      :with => %('groups=' + this.parentNode.parentNode) +
        %(.select('input').map(function(box){return box.getValue()}).compact().toString())
    )

    record_groups = record.groups.map {|g| g.id}
    groups = record.group_checkboxes.map {|k,v| v.values.first} if record.group_checkboxes
    groups ||= record_groups

    # The string "skøyen" and "skøyen" might look the same, but if they don't
    # share the same encoding comparing them will return false. Incoming data
    # in Rails 2.3.x defaults to ASCII-8BIT, thus breaking such comparisons. We
    # force the parameter data to be UTF-8, and everything should be dandy
    # again.
    groups.map! {|id| id.force_encoding "UTF-8"} if RUBY_VERSION.to_f >= 1.9

    out = record.new_record?? "" : %(<div>Groups currently associated with this incident in <b>bold</b>.</div><br/>)
    out << %(<ul id="#{options[:id]}" class="checkbox-list groups">)

    if record and record.id
      stored_groups = Incident.find_by_id(record.id).reload.groups.map {|g| g.id}
    else
      stored_groups = []
    end

    current_user_groups.human_sort {|g| g.name}.each_with_index do |group, index|
      out << %(<li>)
      out << check_box_tag("#{options[:name]}[#{index}][id]", group.id, groups.include?(group.id), :onchange => onchange)

      if stored_groups.include?(group.id)
        out << label_tag("groups", %(<b>#{group.name}</b>))
      else
        out << label_tag("groups", group.name)
      end

      out << %(</li>)
    end

    out << %(<li>No #{link_to "groups", :controller => "admin/groups"} exist!</li>) if current_user_groups.empty?

    out << %(</ul>)
    out << select_links("groups") unless current_user_groups.empty?
    out
  end

  def incident_recipient_fields_form_column(record, options)
    groups = record.group_checkboxes.map {|k,v| v.values.first} if record.group_checkboxes
    groups ||= record.groups.map {|g| g.id}
    groups.map! {|id| id.force_encoding "UTF-8"} if RUBY_VERSION.to_f >= 1.9
    groups.map! {|id| Group.find(id)}

    recipients = groups.inject({}) {|inj, group| inj.merge group.delivery_recipients }
    table = render(:partial => "export/recipient_fields", :locals => { :groups => groups, :recipients => recipients })

    text = %(<noscript><i>Javascript must be enabled for this field to work (it shows you who will recieve any deliveries you check above).</i></noscript>)
    text += %(<div id="#{options[:id]}" style="display: none">#{table}</div>)
    text + javascript_tag(%($('#{options[:id]}').show();))
  end

  private

  # Returns all groups if current_user is admin.
  def current_user_groups
    if current_user.user_type.admin_access?
      Group.all
    else
      current_user.groups
    end
  end

end