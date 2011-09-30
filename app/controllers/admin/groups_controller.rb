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

class Admin::GroupsController < Admin::BaseController
  active_scaffold :group do |config|

    # group information is synced from ldap.
    config.actions = %w{list show search}

    config.show.columns = %w{name complete_description notification_mail} +
      %w{notification_phone reply_to user_memberships member_of_memberships} +
      %w{group_member_memberships valid_from valid_to updated_at created_at}

    config.list.columns = %w{name description member_of_memberships user_memberships valid_from valid_to}
    #config.create.columns = %w{name description notification_mail notification_phone reply_to users member_of}
    #config.update.columns = %w{description notification_mail notification_phone reply_to users member_of}

    config.columns[:users].form_ui = :select
    config.columns[:member_of].form_ui = :select

    config.columns[:users].label = "User members"
    config.columns[:user_memberships].label = "User members"

    config.columns[:member_of].label = "Member of"
    config.columns[:member_of_memberships].label = "Member of"

    config.columns[:group_members].label = "Group members"
    config.columns[:group_member_memberships].label = "Group members"

    config.list.sorting = { :name => :asc }
  end

  protected

  # fix a bug in active scaffold with has-many-trough (hmt) associations:
  # the association is read-only. so we need to save it manually.
  def after_create_save(record)
    update_user_memberships(record)
    update_group_memberships(record)
  end

  def after_update_save(record)
    update_user_memberships(record)
    update_group_memberships(record)
  end

  def update_user_memberships(record)
    checkboxes = Hash.new.replace(params[:record][:users]||{})

    # the format is: :record => {:users => { "0" => {"id" => "4"} }}
    # the first id (0) is the checkbox id: totally irrelevant.
    users = checkboxes.map { |cb_id, hash| hash["id"] }

    value = UserMembership.transaction do
      # destroy all associations
      record.user_memberships.each { |g| g.destroy }

      # create new
      users.each do |id|
        UserMembership.new( :user_id => id, :group_id => record.id ).save!
      end
    end
  end

  def update_group_memberships(record)
    checkboxes = Hash.new.replace(params[:record][:member_of]||{})

    # the format is: :record => {:users => { "0" => {"id" => "4"} }}
    # the first id (0) is the checkbox id: totally irrelevant.
    groups = checkboxes.map { |cg_id, hash| hash["id"] }

    value = GroupMembership.transaction do
      # destroy all associations
      record.member_of_memberships.each { |g| g.destroy }

      # create new
      groups.each do |id|
        GroupMembership.new( :group_id => record.id, :parent_id => id ).save!
      end
    end
  end

end