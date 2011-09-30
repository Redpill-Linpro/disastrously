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

class Group < ActiveRecord::Base
  has_many :user_memberships, :autosave => true, :dependent => :destroy
  has_many :users, :through => :user_memberships, :autosave => true, :dependent => :destroy

  # source must be the opposite/reverse of foreign_key.
  # so when you do group.member_of you get an array of objectes instantiated
  # from the parent column, not the group column (which would be itself).
  has_many :member_of_memberships, :class_name => "GroupMembership", :foreign_key => :group_id, :autosave => true, :dependent => :destroy
  has_many :member_of, :through => :member_of_memberships,
    :source => :parent, :autosave => true, :dependent => :destroy,
    :conditions => ["(valid_from IS NULL OR valid_from <= ?) AND (valid_to IS NULL OR valid_to > ?)", Time.now, Time.now]

  has_many :group_member_memberships, :class_name => "GroupMembership", :foreign_key => :parent_id, :autosave => true, :dependent => :destroy

  # The condition makes sure we only include groups that are actually valid.
  # We leave the original relation (group_member_memberships) unaltered, so
  # that the original information is available if needed.
  has_many :group_members, :through => :group_member_memberships,
    :source => :group, :autosave => true, :dependent => :destroy,
    :conditions => ["(valid_from IS NULL OR valid_from <= ?) AND (valid_to IS NULL OR valid_to > ?)", Time.now, Time.now]

  has_many :incident_relations, :class_name => "IncidentToGroup", :dependent => :destroy
  has_many :incidents, :through => :incident_relations

  include Group::SLA

  attr_readonly :id, :name

  before_validation :fix_empty_strings

  validates_presence_of   :name
  validates_uniqueness_of :name

  validates_format_of :notification_phone, :with => /\A\+?[ ()0-9]+\Z/i, :allow_nil => true
  validates_format_of :notification_mail, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_nil => true
  validates_format_of :reply_to, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_nil => true

  before_create :set_id

  # Returns a hash of delivery type codes paired with an array of group
  # recipients of that delivery type.
  def delivery_recipients
    groups = [self, self.all_group_members].flatten

    recipients = {}

    groups.each do |group|
      recipients[group.name] = {}

      DeliveryType.all.each do |delivery_type|
        recipient_field = delivery_type.group_recipient_field

        # Note: Just because the attribute exists doesn't mean it's not nil.
        recipient = group.send(recipient_field) if recipient_field and group.respond_to?(recipient_field)

        recipients[group.name][delivery_type.code] = recipient if recipient.to_s.chars.any?
      end
    end

    recipients
  end

  def to_param
    self.name
  end

  # Return all incidents for all the groups this group is a member of,
  # recursively. Also filter out incidents that ended before the relation to
  # the group for that incident was created.
  def all_member_of_incidents
    all_member_of.map do |group|
      # Note: If the relation is updated to something else, then using
      # created_at would be incorrect. If the relation is updated needlessly
      # then updated_at would be incorrect..
      membership_start = member_of_memberships.find_by_parent_id(group.id).created_at
      group.incidents.find_all {|i| i.ended_at >= membership_start }
    end.flatten
  end

  # Return all groups that this group is a member of, recursively
  # (meaning directly or indirectly).
  def all_member_of
    groups = {}
    buffer = self.member_of.compact

    while group = buffer.shift
      unless groups[group]
        groups[group] = true
        buffer.concat group.member_of.compact
      end
    end

    groups.keys
  end

  # Return all groups that are a member of this group, recursively
  # (meaning directly or indirectly).
  def all_group_members
    groups = {}
    buffer = self.group_members.compact

    while group = buffer.shift
      unless groups[group]
        groups[group] = true
        buffer.concat group.group_members.compact
      end
    end

    groups.keys
  end

  protected

  def set_id
    # the id must be the same as the name.
    # normally one would just remove the id and just use the name,
    # but rails heavily assumes that we've got an id, so it's easier to
    # "go with the flow" rather than againts it.
    self.id = self.name
  end

  # Allow nil, but not empty strings. Keeps the stored data more consistent.
  def fix_empty_strings
    %w(notification_mail notification_phone reply_to).each do |column|
      send("#{column}=", nil) if send(column).to_s.empty?
    end
  end
end