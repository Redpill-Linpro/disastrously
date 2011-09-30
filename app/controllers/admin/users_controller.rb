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

class Admin::UsersController < Admin::BaseController
  active_scaffold :user do |config|

    # you need to update a user in order to give permissions
    # and group relations.
    # creating users should not be done since we get these from ldap.
    config.actions = %w{list show update search}

    config.show.columns = %w{username full_name user_memberships updated_at created_at}
    config.list.columns = %w{username full_name user_memberships created_at}
    config.update.columns = %w{user_type groups}
    #config.update.columns = %w{username full_name password user_type groups}
    #config.create.columns = %w{username full_name password user_type groups}

    config.columns[:user_type].form_ui = :select
    config.columns[:groups].form_ui = :select

    config.list.sorting = { :username => :asc }
  end

  protected

  def before_create_save(record)
    record.group_checkboxes = params[:record][:groups]

    # This isn't exactly foul proof,
    # but if there is a concurrency issue the create will fail
    # (and display a 500 error), and the user can just try again.
    highest_id = User.all(:limit => 1, :order => "id DESC").first.id
    record.id = highest_id + 1
  end

  def before_update_save(record)
    record.group_checkboxes = params[:record][:groups]

    if record.password.to_s.empty?
      # the password is empty when the user didn't type in a new password,
      # so just insert the old one.
      record.password = record.password_was
    else
      # update the password with the unencrypted version typed in by the user,
      # in order to encrypt it.
      record.update_password(record.password)
    end
  end

  def after_create_save(record)
    update_user_memberships(record)
  end

  def after_update_save(record)
    update_user_memberships(record)
  end

  def update_user_memberships(record)
    # fix a bug in active scaffold with has-many-trough (hmt) associations:
    # the association is read-only. so we need to save it manually.
    checkboxes = (params[:record][:groups]||{}).merge({})

    # the format is: :record => {:groups => { "0" => {"id" => "4"} }}
    # the first id (0) is the checkbox id: totally irrelevant.
    groups = checkboxes.map { |cb_id, hash| hash["id"] }

    UserMembership.transaction do
      # destroy all associations
      record.user_memberships.each { |g| g.destroy }

      # create new
      groups.each do |id|
        UserMembership.new( :user_id => record.id, :group_id => id ).save!
      end
    end
  end

end